To reset and rejoin a worker node in your Kubernetes cluster, you’ll need to clean up its current state and then join it back to the master node (`master-node`, IP: `192.168.1.181`). This is necessary if the worker was part of the previous cluster or if you’ve reset the master and need to reestablish the cluster. Below is a step-by-step guide to reset and rejoin a worker node using `kubeadm`, Calico, and containerd.

---

### Prerequisites
- **Master Node**: Assumed to be running (e.g., after `kubeadm init` with Calico applied). IP: `192.168.1.181`
- **Worker Node**: Worker Node.
- **Join Command**: You’ll need the `kubeadm join` command from the master node.

---

### Step 1: Reset the Worker Node
Resetting removes the worker’s Kubernetes components and configurations.

1. **Run `kubeadm reset`**:
   On the worker node:
   ```bash
   sudo kubeadm reset
   ```
   - This stops the kubelet, removes cluster data, and cleans up networking.

2. **Confirm Prompt**:
   - You’ll see:
     ```
     Are you sure you want to proceed? [y/N]
     ```
   - Type `y` and press Enter.

3. **Clean Up Residual Files**:
   - Remove leftover CNI and kubelet files:
     ```bash
     sudo rm -rf /etc/cni/net.d/*
     sudo rm -rf /var/lib/kubelet/*
     sudo rm -rf /var/lib/cni/*
     ```
   - Clear iptables (optional, if networking persists):
     ```bash
     sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
     ```

4. **Restart Services**:
   - Ensure containerd and kubelet are reset:
     ```bash
     sudo systemctl restart containerd
     sudo systemctl restart kubelet
     ```

5. **Verify Cleanup**:
   - Check no Kubernetes processes are running:
     ```bash
     ps aux | grep kube
     ```
   - Should show only the kubelet service (if running) but no cluster-specific processes.

---

### Step 2: Get the Join Command from Master Node
If you don’t have the `kubeadm join` command from the master’s latest `kubeadm init`:

1. **On `master-node`**:
   ```bash
   kubeadm token create --print-join-command
   ```
   - Example output:
     ```
     kubeadm join 192.168.1.181:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
     ```
   - Copy this command.

---

### Step 3: Rejoin the Worker Node
Rejoin the worker to the cluster using the join command.

1. **Run `kubeadm join`**:
   On the worker node (`k8s-worker1` or `k8s-worker2`):
   ```bash
   sudo kubeadm join 192.168.1.181:6443 \
     --token <token> \
     --discovery-token-ca-cert-hash sha256:<hash> \
     --cri-socket=unix:///run/containerd/containerd.sock
   ```
   - Replace `<token>` and `<hash>` with the values from the master.
   - `--cri-socket`: Specifies containerd as the runtime, matching your setup.

2. **Output**:
   - You’ll see messages about preflight checks, joining the cluster, and a success message like:
     ```
     This node has joined the cluster:
     * Certificate signing request was sent to apiserver and a response was received.
     * The Kubelet was informed of the new secure connection details.
     ```

---

### Step 4: Verify from Master Node
Check the cluster state from `master-node`.

1. **Check Nodes**:
   ```bash
   kubectl get nodes -o wide
   ```
   - Expect to see `k8s-worker1` (or `k8s-worker2`) listed, initially `NotReady` until Calico starts.

2. **Check Pods**:
   ```bash
   kubectl get pods -n kube-system -o wide
   ```
   - Look for new `calico-node` and `kube-proxy` pods on the worker node, transitioning to `Running`.

---

### Step 5: Repeat for Other Worker
If resetting and rejoining `k8s-worker2` (or vice versa):
- Repeat Steps 1-3 on the second worker node using the same join command.

---

### Troubleshooting
- **Join Fails**:
  - **Error: "connection refused"**: Check firewall on master (`sudo firewall-cmd --list-all`, ensure 6443/tcp is open).
  - **Error: "token invalid"**: Regenerate the token on master with `kubeadm token create --print-join-command`.
  - Check logs: `journalctl -u kubelet | tail -50` on the worker.
- **Node NotReady**:
  - Ensure `calico-node` pod is running on the worker:
    ```bash
    kubectl get pods -n kube-system -o wide | grep <worker-name>
    ```
  - Check logs: `kubectl logs <calico-node-pod> -n kube-system`.

---

### Full Cluster Verification
Once both workers are joined:
1. **Nodes**:
   ```bash
   kubectl get nodes -o wide
   ```
   - Expect: `master-node` and `worker node` all `Ready`.

2. **Pods**:
   ```bash
   kubectl get pods -n kube-system -o wide
   ```
   - Expect `calico-node` and `kube-proxy` on each node, plus `coredns` and `calico-kube-controllers`.

3. **Test**:
   ```bash
   kubectl create deployment nginx --image=nginx --replicas=3
   kubectl expose deployment nginx --port=80 --type=NodePort
   kubectl get pods,svc -o wide
   ```
   - Pods should spread across all nodes.

---

### Summary
- **Reset**: `sudo kubeadm reset` and clean up files on the worker.
- **Rejoin**: Use the `kubeadm join` command from the master with `--cri-socket`.
- **Verify**: Check nodes and pods from `master-node`.

Start by resetting one worker (e.g., `k8s-worker1`), then run the join command. Share the output of `kubectl get nodes -o wide` from `master-node` after joining—I’ll confirm it’s all set! 🚀 
