## Set Up Your Workstation

To work with your Kubernetes cluster from your workstation PC or laptop, you'll need to set up your local environment to interact with the cluster using tools like `kubectl`, the Kubernetes command-line tool. Below are the detailed steps to achieve this:

---

### Prerequisites
- A functioning Kubernetes cluster with one master node and two worker nodes.
- Your workstation PC (Windows, macOS, or Linux).
- Network access between your workstation and the master node (e.g., via a VPN, public IP, or local network).
- SSH access to the master node (optional but helpful for troubleshooting).

---

### Steps to Set Up Your Workstation

#### 1. Install `kubectl` on Your Workstation
`kubectl` is the tool you'll use to interact with your Kubernetes cluster. Install it based on your operating system:

- **Linux:**
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  ```

- **macOS:**
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  ```

- **Windows (using PowerShell):**
  ```powershell
  curl -LO https://dl.k8s.io/release/v1.29.0/bin/windows/amd64/kubectl.exe
  # Move it to a directory in your PATH, e.g., C:\Users\<YourUser>\bin
  Move-Item -Path .\kubectl.exe -Destination "C:\Users\<YourUser>\bin"
  # Add the directory to your PATH environment variable
  ```

Verify the installation:
```bash
kubectl version --client
```

#### 2. Obtain the Kubernetes Configuration File (Kubeconfig)
To communicate with your cluster, you need the `kubeconfig` file, which contains cluster details, credentials, and context. This file is typically located on the master node.

- **Locate the kubeconfig file on the master node:**
  By default, it’s usually at `~/.kube/config` on the master node (assuming the cluster was set up with a tool like `kubeadm`).

- **Copy the file to your workstation:**
  Use `scp` or a similar tool to transfer it:
  ```bash
  scp user@<master-node-ip>:~/.kube/config ~/.kube/config
  ```
  Replace `<master-node-ip>` with the actual IP address of your master node and `user` with your SSH username.

- **Set permissions (Linux/macOS):**
  ```bash
  chmod 600 ~/.kube/config
  ```

- **Alternative: Manually generate kubeconfig (if needed):**
  If the config file isn’t available or you need to create one:
  1. On the master node, check cluster details:
     ```bash
     kubectl cluster-info
     ```
  2. Extract the cluster certificate and user credentials (this depends on how your cluster was set up—consult your cluster admin or documentation if unsure).

#### 3. Verify Connectivity to the Cluster
Test that your workstation can communicate with the cluster:
```bash
kubectl get nodes
```
You should see output listing your master and two worker nodes, e.g.:
```
NAME         STATUS   ROLES    AGE   VERSION
master-node  Ready    master   10d   v1.29.0
worker1      Ready    <none>   10d   v1.29.0
worker2      Ready    <none>   10d   v1.29.0
```

If you get an error (e.g., "connection refused"), ensure:
- The master node’s API server is reachable (check firewall rules, usually port 6443).
- The `kubeconfig` file points to the correct cluster endpoint (edit `~/.kube/config` if needed).

#### 4. Configure Your Shell (Optional)
To make `kubectl` usage easier:
- **Enable autocomplete (Linux/macOS):**
  ```bash
  source <(kubectl completion bash) # For Bash
  echo "source <(kubectl completion bash)" >> ~/.bashrc
  # For Zsh: replace "bash" with "zsh"
  ```
- **Set default context (if multiple clusters are in kubeconfig):**
  ```bash
  kubectl config use-context <context-name>
  ```
  Find `<context-name>` with:
  ```bash
  kubectl config get-contexts
  ```

#### 5. Install Additional Tools (Optional)
- **Kubeconfig Management (e.g., `kubectx` and `kubens`):**
  Simplifies switching between clusters and namespaces:
  ```bash
  # Linux/macOS
  git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
  sudo ln -s ~/.kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s ~/.kubectx/kubens /usr/local/bin/kubens
  ```
- **Kubernetes Dashboard (optional):**
  If your cluster has the dashboard installed, access it via:
  ```bash
  kubectl proxy
  ```
  Then open `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/` in your browser.

#### 6. Test a Simple Deployment
Deploy a sample application to ensure everything works:
```bash
kubectl run nginx --image=nginx --restart=Never
kubectl get pods
```
If you see the `nginx` pod running, your setup is successful!

---

### Troubleshooting Tips
- **"Unable to connect to the server":**
  Check the master node’s IP in `~/.kube/config` and ensure port 6443 is open.
- **Permission denied:**
  Verify your user in `kubeconfig` has the correct credentials or RBAC permissions.
- **Nodes not showing:**
  Run `kubectl get nodes --v=6` for verbose output to debug.

---

Now you’re ready to manage your Kubernetes cluster from your workstation! 