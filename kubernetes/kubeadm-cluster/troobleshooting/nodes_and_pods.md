Your output shows a healthy cluster on `k8s-master` with all pods in the `kube-system` namespace running successfully—great work! You’ve noticed that the IP addresses assigned to the pods fall into two different ranges: `192.168.1.190` and `172.17.235.193-196`. This is expected behavior in a Kubernetes cluster and reflects the distinction between *node IPs* and *pod IPs*. Let me explain why this happens and how it ties into your setup with kubeadm, Calico, and containerd.

---

### Why Different IP Ranges?
In Kubernetes, IP addresses are assigned based on the type of component and the networking configuration:

1. **Node IPs (`192.168.1.190`)**:
   - Pods like `etcd-k8s-master`, `kube-apiserver-k8s-master`, `kube-controller-manager-k8s-master`, `kube-scheduler-k8s-master`, and `calico-node-dtbnz` have the IP `192.168.1.190`.
   - **Reason**: These are *host-networked pods*, meaning they run directly on the node’s network stack and use the node’s IP address (`192.168.1.190`, your `k8s-master` static IP).
   - **Details**:
     - Control plane components (`etcd`, `kube-apiserver`, etc.) are static pods managed by the kubelet and configured to use `hostNetwork: true` in their manifests (located in `/etc/kubernetes/manifests/`).
     - `calico-node` also uses `hostNetwork: true` because it needs direct access to the node’s network interfaces to manage Calico’s networking (e.g., BGP, IP routing).

2. **Pod IPs (`172.17.235.193-196`)**:
   - Pods like `calico-kube-controllers-7ddc4f45bc-d2kgh`, `coredns-64ff69f7fc-kp4gm`, and `coredns-64ff69f7fc-z555c` have IPs in the `172.17.235.0/24` range.
   - **Reason**: These are *regular pods* that run in the Kubernetes pod network, which is managed by the Container Network Interface (CNI) plugin—Calico in your case.
   - **Details**:
     - When you initialized the cluster with `kubeadm init --pod-network-cidr=192.168.0.0/16`, you specified the pod network CIDR, which defines the range of IPs available for pods.
     - Calico allocates pod IPs from this range (or a subset of it), but in your output, it’s using `172.17.235.0/24`. This mismatch suggests Calico might be overriding the default CIDR or using an unexpected range.

---

### Understanding the IP Ranges
- **`192.168.1.190`**:
  - This is your node’s physical (or virtual) network IP, set via `nmcli` earlier (`192.168.1.190/24`).
  - Pods using `hostNetwork: true` inherit this IP because they don’t get a separate network namespace—they share the node’s.

- **`172.17.235.193-196`**:
  - These are pod IPs assigned by Calico from its configured IP pool.
  - **Unexpected Range**: You specified `--pod-network-cidr=192.168.0.0/16` during `kubeadm init`, so you’d expect pod IPs in that range (e.g., `192.168.x.y`). The appearance of `172.17.235.0/24` suggests:
    1. Calico’s default IP pool might not have been updated to match your specified CIDR.
    2. A misconfiguration or fallback to a default range (possibly from an earlier setup or Calico’s defaults).

---

### Why This Matters
- **Functionality**: The cluster works fine with these IPs because:
  - `hostNetwork` pods need the node IP to operate correctly (e.g., API server on `192.168.1.190:6443`).
  - Pod IPs (e.g., `172.17.235.x`) are routable within the cluster via Calico, allowing communication between pods.
- **Potential Issue**: The mismatch between your `--pod-network-cidr=192.168.0.0/16` and the actual pod IPs (`172.17.235.x`) could cause confusion or conflicts later, especially when joining worker nodes or scaling the cluster.

---

### Steps to Investigate and Fix

#### 1. Verify Pod Network CIDR
Check the cluster’s configuration:
```bash
kubectl describe cm kubeadm-config -n kube-system
```
- Look for `podSubnet` under `ClusterConfiguration`. It should say `192.168.0.0/16`.

#### 2. Check Calico IP Pool
Calico manages pod IPs via its `IPPool` resource:
```bash
kubectl get ippool -n kube-system
```
- If no output, Calico is using a default pool. Fetch the default:
  ```bash
  kubectl get ippool default-ipv4-ippool -n kube-system -o yaml
  ```
- Expected `spec.cidr` should be `192.168.0.0/16`. If it’s `172.17.235.0/24` or similar, it’s misconfigured.

Fix the IP pool (if needed):
- Edit the pool:
  ```bash
  kubectl edit ippool default-ipv4-ippool -n kube-system
  ```
- Set `spec.cidr` to `192.168.0.0/16`:
  ```yaml
  spec:
    cidr: 192.168.0.0/16
  ```
- Restart Calico pods:
  ```bash
  kubectl delete pod -l k8s-app=calico-node -n kube-system
  kubectl delete pod -l k8s-app=calico-kube-controllers -n kube-system
  ```
- New pods should use `192.168.x.y` IPs.

#### 3. Verify Node Status
Since `kube-proxy` is still missing, the node might be `NotReady`:
```bash
kubectl get nodes -o wide
```

#### 4. Deploy Kube-Proxy
Add `kube-proxy` to complete the setup:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubeadm/master/hack/static-yaml/kube-proxy.yaml
```
Check:
```bash
kubectl get pods -n kube-system -o wide | grep kube-proxy
```

#### 5. Re-Verify IPs
After fixing the IP pool and adding `kube-proxy`:
```bash
kubectl get pods -n kube-system -o wide
```
- Pod IPs should align with `192.168.0.0/16` if you updated the IP pool.

---

### Should You Fix the IP Mismatch?
- **If It’s Working**: The `172.17.235.x` range isn’t inherently wrong if it’s routable and doesn’t conflict with your physical network (`192.168.1.0/24`). You can leave it as-is for now and proceed with joining workers.
- **For Consistency**: Update the Calico IP pool to match `192.168.0.0/16` to align with your `kubeadm init` configuration.

---

### Next Steps
1. Deploy `kube-proxy` (Step 4).
2. Check the IP pool (Step 2) and decide if you want to fix it.
3. Join the worker nodes:
   ```bash
   kubeadm token create --print-join-command
   ```
   On `k8s-worker1` and `k8s-worker2`:
   ```bash
   sudo kubeadm join 192.168.1.190:6443 \
     --token <token> \
     --discovery-token-ca-cert-hash sha256:<hash> \
     --cri-socket=unix:///run/containerd/containerd.sock
   ```

Share the output of `kubectl get nodes -o wide` and `kubectl get pods -n kube-system -o wide` after adding `kube-proxy`—I’ll confirm everything’s set! 🚀 The IP difference is normal due to `hostNetwork` vs. pod network; we just need to ensure consistency if desired.
