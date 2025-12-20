Since you’d like to reset and reinitialize the master node (`master-node`) to ensure a clean setup—potentially to align the pod network CIDR or simply start fresh—here’s a detailed guide to do so. This will wipe the current cluster state on the master node and set it up anew with `kubeadm`, Calico, and containerd. I’ll assume you want to use `172.16.0.0/16` (Calico’s default) as the pod network CIDR since it’s working well for you, but I’ll also show how to adjust it if you prefer `192.168.0.0/16` or another range.

---

### Prerequisites
- **Node**: `master-node` (IP: `192.168.1.181`).
- **Workers**: If `k8s-worker1` and `k8s-worker2` are already joined, you’ll need to reset them too (Step 5).
- **Backup**: If you have any critical data (e.g., deployments), back them up, as this process will erase everything on the master.

---

### Step 1: Reset the Master Node
Resetting removes all Kubernetes components, configurations, and networking setup.

1. **Run `kubeadm reset`**:
   ```bash
   sudo kubeadm reset
   ```
   - This stops the kubelet, removes cluster data (e.g., `/etc/kubernetes/`), and cleans up CNI configurations (e.g., `/etc/cni/net.d/`).

2. **Confirm Prompt**:
   - You’ll see a prompt like:
     ```
     Are you sure you want to proceed? [y/N]
     ```
   - Type `y` and press Enter.

3. **Clean Up Residual Files**:
   - Remove leftover files:
     ```bash
     sudo rm -rf /etc/kubernetes/*
     sudo rm -rf /var/lib/etcd/*
     sudo rm -rf /var/lib/kubelet/*
     sudo rm -rf /etc/cni/net.d/*
     sudo rm -rf ~/.kube/*
     ```
   - Clear iptables (optional, if networking persists):
     ```bash
     sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
     ```

4. **Restart Services**:
   - Ensure containerd and kubelet are in a clean state:
     ```bash
     sudo systemctl restart containerd
     sudo systemctl restart kubelet
     ```

---

### Step 2: Reinitialize the Master Node
Now, reinitialize the cluster with `kubeadm init`. I’ll provide the command with `172.16.0.0/16` (matching Calico’s default), but you can adjust the CIDR if desired.

1. **Run `kubeadm init`**:
   ```bash
   sudo kubeadm init \
     --pod-network-cidr=172.16.0.0/16 \
     --control-plane-endpoint=192.168.1.181 \
     --cri-socket=unix:///run/containerd/containerd.sock
   ```
   - **`--pod-network-cidr=172.16.0.0/16`**: Matches Calico’s default, avoiding extra configuration.
   - **`--control-plane-endpoint=192.168.1.181`**: Uses the master’s static IP.
   - **`--cri-socket`**: Specifies containerd as the runtime.

   **Alternative CIDR** (if you prefer):
   - For `192.168.0.0/16`:
     ```bash
     --pod-network-cidr=192.168.0.0/16
     ```
   - For `10.244.0.0/16` (common alternative):
     ```bash
     --pod-network-cidr=10.244.0.0/16
     ```

2. **Capture Join Command**:
   - The output will include a `kubeadm join` command, e.g.:
     ```
     kubeadm join 192.168.1.181:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
     ```
   - Save this for Step 5 (joining workers).

3. **Configure `kubectl`**:
   ```bash
   mkdir -p $HOME/.kube
   sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

4. **Verify Initialization**:
   ```bash
   kubectl get nodes
   kubectl get pods -n kube-system
   ```
   - Expect `master-node` (possibly `NotReady` until networking is applied) and control plane pods starting.

---

### Step 3: Apply Calico Networking
Install Calico to enable pod networking:

1. **Apply Calico Manifest**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
   ```

2. **Verify Pods**:
   - Wait a minute, then check:
     ```bash
     kubectl get pods -n kube-system -o wide
     ```
   - Expect `calico-node`, `calico-kube-controllers`, `coredns`, and `kube-proxy` pods to appear and eventually reach `Running`.

3. **Check IPPool (Optional)**:
   - If you used `172.16.0.0/16`, Calico’s default IPPool matches—no changes needed.
   - If you used a different CIDR (e.g., `192.168.0.0/16`):
     ```bash
     kubectl edit ippool default-ipv4-ippool -n kube-system
     ```
     Update `spec.cidr` to match (e.g., `192.168.0.0/16`), then restart Calico pods:
     ```bash
     kubectl delete pod -l k8s-app=calico-node -n kube-system
     kubectl delete pod -l k8s-app=calico-kube-controllers -n kube-system
     ```

---

### Step 4: Verify Master Node
1. **Check Node Status**:
   ```bash
   kubectl get nodes -o wide
   ```
   - `master-node` should be `Ready` once Calico and `kube-proxy` are running.

2. **Check Pods**:
   ```bash
   kubectl get pods -n kube-system -o wide
   ```
   - Ensure all pods are `1/1 Running`.

---

### Step 5: Reset and Join Worker Nodes (If Previously Joined)
If `k8s-worker1` and `k8s-worker2` were part of the old cluster:

1. **Reset Workers**:
   On each worker (`k8s-worker1`, `k8s-worker2`):
   ```bash
   sudo kubeadm reset
   sudo rm -rf /etc/cni/net.d/*
   sudo systemctl restart containerd
   sudo systemctl restart kubelet
   ```

2. **Join Workers**:
   Use the `kubeadm join` command from Step 2:
   ```bash
   sudo kubeadm join 192.168.1.181:6443 \
     --token <token> \
     --discovery-token-ca-cert-hash sha256:<hash> \
     --cri-socket=unix:///run/containerd/containerd.sock
   ```

3. **Verify Cluster**:
   On `master-node`:
   ```bash
   kubectl get nodes -o wide
   ```

---

### Step 6: Test the Cluster
Deploy a test workload:
```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pods,svc -o wide
```

---

### Troubleshooting
- **Pods Stuck**: Check logs (e.g., `kubectl logs <pod-name> -n kube-system`).
- **Node Not Ready**: Ensure `kube-proxy` and `calico-node` are running.
- **Join Fails**: Verify firewall ports (6443/tcp) and worker logs (`journalctl -u kubelet`).

---

### Recommended Command
For simplicity and alignment with Calico’s default:
```bash
sudo kubeadm reset
sudo kubeadm init \
  --pod-network-cidr=172.16.0.0/16 \
  --control-plane-endpoint=192.168.1.181 \
  --cri-socket=unix:///run/containerd/containerd.sock
```

If you prefer `192.168.0.0/16` or `10.244.0.0/16`, adjust the `--pod-network-cidr` and update the IPPool post-Calico application.

---

### Next Steps
Run the reset and reinitialization on `master-node`, then apply Calico. Share the output of `kubectl get nodes -o wide` and `kubectl get pods -n kube-system -o wide` after Step 4—I’ll confirm the master is ready before you join the workers! 🚀 Ready to proceed?
