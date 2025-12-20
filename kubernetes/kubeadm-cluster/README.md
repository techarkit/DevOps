## Install Kubernetes Cluster with Kubeadm

---

## **Architecture Overview**
You will set up a Kubernetes cluster using `kubeadm` with the following architecture:

- **Host Machine:** Ubuntu (High-End System)
- **Virtual Machines:**  
  - **1 Control Plane Node (Master)**
  - **2 Worker Nodes**
- **Operating System on VMs:** AlmaLinux 9
- **Networking:** Flannel (or Calico for network policies)
- **Container Runtime:** Containerd
- **Pod Network CIDR:** `172.16.0.0/16`
- **Kubernetes Version:** Latest stable (v1.32) https://kubernetes.io/releases/

---

## **Step-by-Step Guide to Deploy Kubernetes on AlmaLinux using kubeadm**

### **Step 1: Install VirtualBox and Create Virtual Machines**

#### **1.1 Install VirtualBox (if not installed)**
If VirtualBox is not installed, run:
```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack -y
```

### **1.2 Create Three Virtual Machines**
1. Open VirtualBox and create **three VMs** with the following specs:
   - **VM Name:** `master-node`, `worker-node1`, `worker-node2`
   - **OS:** AlmaLinux 9
   - **CPU:** At least 2 vCPUs
   - **RAM:** 4GB minimum (8GB recommended)
   - **Storage:** 30GB (Dynamically allocated)
   - **Network:** **Bridged Adapter** (or Host-Only Adapter for local testing)

**Attach ISO & Install AlmaLinux 9** on all VMs.

---

### Update System:  

```bash
sudo dnf update -y && sudo dnf upgrade -y
sudo reboot
cat /etc/os-release  # Verify update
```

(Optional cleanup):  
```bash
sudo dnf autoremove -y && sudo dnf clean all
```

---

### **Set Hostnames & Static IPs**  
   Modify `/etc/hostname` on each VM:
   ```bash
   echo "master-node" | sudo tee /etc/hostname
   ```

---
### **enable **port 22** (SSH)**

To enable **port 22** (SSH) with **firewalld**, use the following guide:

https://github.com/jahangir842/linux-notes/blob/main/firewall/firewalld.md

---
### Static IPs

To Set static IP addresses, use the following guide:

https://github.com/jahangir842/linux-notes/blob/main/networking/configure_static_ip_in_RHEL_based_new.md

---

### **1. Update the `/etc/hosts` file**  
Edit the `/etc/hosts` file on **all nodes** (Master and Workers) using:  
```bash
sudo nano /etc/hosts
```
Add the following lines:
```
192.168.1.181  master-node
192.168.1.182  worker-node-1
192.168.1.183  worker-node-2
```
Save and exit (`CTRL+X`, then `Y`, then `ENTER`).

---

### **Disable Swap on all nodes:**

   ```bash
   sudo swapoff -a
   sudo sed -i '/swap/d' /etc/fstab
   ```

---

## **Step 2: Install Required Dependencies**
Perform the following steps on **all three nodes** to set up a stable Kubernetes environment.


### **1. Update System Packages**
Keeping the system updated ensures that you have the latest security patches and bug fixes.
```bash
sudo dnf update -y
```

### **2. Configure SELinux (Set to Permissive Mode)**
Kubernetes does not work well with SELinux in **Enforcing** mode by default, so we set it to **Permissive**.

**Learn more about Selinux Notes:** https://github.com/jahangir842/linux-notes/blob/main/selinux/1.Introduction_selinux.md

#### Check the status:

```bash
sudo getenforce
```

#### **Temporarily Disable SELinux (Immediate Effect)**
```bash
sudo setenforce 0
```
- This command **temporarily** sets SELinux to **Permissive mode** until the next reboot.

#### **Permanently Disable SELinux (After Reboot)**
```bash
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```
- This modifies `/etc/selinux/config` to ensure SELinux remains **Permissive** even after a reboot.

6. **Configure Firewall**
```bash
sudo firewall-cmd --permanent --add-port=6443/tcp    # Kubernetes API Server
sudo firewall-cmd --permanent --add-port=2379-2380/tcp  # etcd
sudo firewall-cmd --permanent --add-port=10250/tcp   # Kubelet
sudo firewall-cmd --permanent --add-port=10251/tcp   # Scheduler
sudo firewall-cmd --permanent --add-port=10252/tcp   # Controller
sudo firewall-cmd --permanent --add-port=179/tcp     # Calico BGP
sudo firewall-cmd --reload
```

6. **List Active Firewall Rules**
To view all active firewall rules:
```bash
sudo firewall-cmd --list-all
```

**More for firewalld** : https://github.com/jahangir842/linux-notes/blob/main/firewall/firewalld.md

7. **Load Kernel Modules** (Verify its required or not?????)
```bash
sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system
```

### **3. Enable IP Forwarding**
IP forwarding is essential for Kubernetes networking to function correctly.

#### **Create a Configuration File**
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```
- **`net.bridge.bridge-nf-call-iptables = 1`** → Ensures traffic passes through `iptables` rules for filtering.
- **`net.bridge.bridge-nf-call-ip6tables = 1`** → Same as above but for IPv6.
- **`net.ipv4.ip_forward = 1`** → Enables packet forwarding for Kubernetes networking.

#### **Apply the Changes Immediately**
```bash
sudo sysctl --system
```
- This reloads system kernel parameters from all config files (`/etc/sysctl.d/`).

### **4. Install Container Runtime (containerd)**
Kubernetes requires a **container runtime** to run its workloads. We will use **containerd**.

#### **Install containerd**

Kubernetes requires a **container runtime** to run its workloads. We will use **containerd**.

**Official Link:** https://docs.docker.com/engine/install/centos/

**Note:** The containerd is provided to linux package managers from Docker.

#### Set up the repository

Install the dnf-plugins-core package (which provides the commands to manage your DNF repositories) and set up the repository.
```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

```bash
sudo dnf install -y containerd.io
```

2. **Configure Containerd**

Create configuration file if now available already.
```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

### Create Containerd Configuration(If not created automatically)

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```
- Creates the necessary **configuration directory** (`/etc/containerd`).
- Generates and saves the default **containerd configuration**.

---

### Updated `config.toml` for Kubernetes
Here’s how your `/etc/containerd/config.toml` should look after modification. This is based on the default output from `containerd config default`, tailored for Kubernetes with kubeadm:

```toml
# Copyright 2018-2022 Docker Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

version = 2
root = "/var/lib/containerd"
state = "/run/containerd"
oom_score = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  uid = 0
  gid = 0

[debug]
  address = "/run/containerd/debug.sock"
  uid = 0
  gid = 0
  level = "info"

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.k8s.io/pause:3.9"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
```


**for more info:** https://github.com/jahangir842/kubernetes-notes/blob/main/kubeadm-grok/containerd_config.md

4. **Start Containerd**
```bash
sudo systemctl enable containerd
sudo systemctl start containerd
```

#### **Restart and Enable containerd**
```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```
- **Restart** containerd to apply the configuration.
- **Enable** it to start automatically at boot.

---

### **Step 3: Install Kubernetes Components**  

To set up a Kubernetes cluster using `kubeadm`, follow these steps to install the required components.

---

### **1️⃣ Install Kubeadm, Kubelet, and Kubectl**  
Before installing Kubernetes components, ensure that your system meets the prerequisites. Follow the official Kubernetes documentation for installation details:  

🔗 **Install Kubeadm:** https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

🔗 **Creating a cluster with kubeadm:** https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

---

### **2️⃣ Add Kubernetes Repository**  
The Kubernetes packages are provided via an official repository. To add it, run the following command:  

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

#### **📝 Explanation:**
- **`baseurl`**: Specifies the official Kubernetes package repository.  
- **`gpgcheck=1`**: Ensures package authenticity via GPG verification.  
- **`exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni`**:  
  - Prevents unintended package updates when running `dnf update`.  
  - Ensures stability by locking Kubernetes to a specific version.  

✅ **Tip**: To learn more about locking package versions, check this guide:  
🔗 **[Locking Packages in DNF/YUM](https://github.com/jahangir842/linux-notes/blob/main/packages/dnf_yum/locking_version.md)**  

---

### **3️⃣ Install Kubernetes Components**  
Now, install the required Kubernetes packages:

```bash
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

#### **📝 Explanation:**
- **`kubelet`**: The primary node agent that runs pods.  
- **`kubeadm`**: Tool to bootstrap and manage a Kubernetes cluster.  
- **`kubectl`**: CLI tool to interact with Kubernetes API.  
- **`--disableexcludes=kubernetes`**:  
  - Temporarily overrides the `exclude` setting in `kubernetes.repo`.  
  - Allows installing the specified Kubernetes components.  

✅ **After installation, enable and start the `kubelet` service:**

```bash
sudo systemctl enable --now kubelet
```

---

### **4️⃣ Verify the Installation**
Check the installed Kubernetes component versions:  

```bash
kubeadm version
kubectl version --client
kubelet --version
```

🔹 If the output shows valid versions, your Kubernetes components are successfully installed! 🚀  

Would you like to proceed with cluster initialization using `kubeadm init`? Let me know!

---

Now you have a **fully functional Kubernetes cluster** running on AlmaLinux VMs in VirtualBox! 🚀

### Next Step:

- Configure Master Node: https://github.com/jahangir842/kubernetes-notes/blob/main/kubeadm/2.configure_master_node.md
- Configure Worker Node: https://github.com/jahangir842/kubernetes-notes/blob/main/kubeadm/3.configure_worker_node.md
