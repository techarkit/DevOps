## Minikube on Ubuntu

**Geting Started:** https://minikube.sigs.k8s.io/docs/start/

**Official Docs:** https://minikube.sigs.k8s.io/docs/

**Minikube Commands:** https://minikube.sigs.k8s.io/docs/commands/

**Tutorial with Nana:** https://www.youtube.com/watch?v=X48VuDVv0do

minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: minikube start

**Kubernetes in Containers (KIC)** is an architecture where Kubernetes clusters run inside containers instead of virtual machines. This is used by tools like **Minikube** with the **Docker driver**, which spins up Kubernetes nodes (control plane and workers) as lightweight containers. 

### Key Benefits:
- **Faster startup** and **lower resource usage** compared to running full VMs.
- **Efficient networking** using the container runtime’s network.
- Ideal for **local development** and testing.

The **`kicbase`** image is a core part of this setup, acting as the base image for nodes within Minikube's containerized environment.

In short, KIC makes it faster and easier to run Kubernetes clusters locally using containers instead of virtual machines.

### **Installing Dependencies**

1. **Install Driver (Preferred Docker)**

   See the drivers page for help setting up a compatible container or virtual-machine manager. (https://minikube.sigs.k8s.io/docs/drivers/)

   Minikube works well with Docker as a driver. Install Docker using the following commands:

   ```bash
   sudo apt update
   sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   sudo apt update
   sudo apt install -y docker-ce
   ```

2. **Manage Docker as a Non-Root User** (optional but recommended)
   To run Docker without `sudo`, add your user to the Docker group:
   
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **Install `kubectl`**
   Minikube requires `kubectl` to interact with the Kubernetes cluster:

   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

   ```
   **Verify Installation:**

   Test to ensure the version you installed is up-to-date:
   ```
   kubectl version --client
   ```
   Or use this for detailed view of version:
   
   ```
   kubectl version --client --output=yaml

   ```
### Notes: Requirements for Running Minikube

When setting up **Minikube**—a tool for running a local Kubernetes cluster on your workstation—there are specific requirements to ensure the smooth functioning of Minikube. Below is an outline of the essential prerequisites.

---

#### 1. **VT-x/AMD-v Virtualization**

- **What is it?**  
  VT-x (Intel) and AMD-v (AMD) are hardware virtualization technologies that enable your system to run multiple operating systems or containers simultaneously.
  
- **Why is it needed?**  
  Minikube requires virtualization to run Kubernetes nodes within a virtual machine. The most common use case is when using hypervisors like VirtualBox, KVM, or Hyper-V.
  
- **How to check if enabled?**  
  - **Linux**:  
    Run the following command to check if your system supports hardware virtualization:  
    ```bash
    egrep -o '(vmx|svm)' /proc/cpuinfo
    ```
    If the command outputs `vmx` (for Intel) or `svm` (for AMD), your system supports hardware virtualization.  
  - **Windows**:  
    Open **Task Manager**, go to the **Performance** tab, and check if virtualization is enabled.
  - **macOS**:  
    macOS usually has VT-x enabled by default. However, you can check by running a virtual machine like VirtualBox or by confirming through system specifications.

- **Enabling VT-x/AMD-v**:  
  Virtualization is generally enabled through the BIOS/UEFI settings:
  - **Reboot** your computer and enter the BIOS/UEFI setup (usually by pressing keys like `F2`, `F10`, `Del`, etc., during boot).
  - Find the **Virtualization Technology** setting, typically under **Processor**, **Advanced**, or **CPU Configuration**.
  - Enable it, then save and exit.

---

#### 2. **Operating System Compatibility**

Minikube supports the following operating systems:
  - **Linux**: Most distributions such as Ubuntu, CentOS, Fedora, and others are supported.
  - **macOS**: macOS High Sierra 10.13 or later is supported.
  - **Windows**: Windows 10 or later is supported.

---

#### 3. **CPU and Memory**

- **CPU**: At least a **2-core** processor is required for Minikube to run efficiently.
- **Memory**: A minimum of **2GB RAM** is required, but it's recommended to allocate **4GB or more** for better performance when running multiple services in Kubernetes.

---

#### 4. **Hypervisor**

A hypervisor is necessary if you want to run Minikube in a virtualized environment. Below are common hypervisors:
  - **VirtualBox**: Cross-platform support and easy setup.
  - **Hyper-V**: Built-in for Windows, but must be enabled manually.
  - **KVM**: Commonly used in Linux environments.
  - **Docker**: Minikube can run using Docker's container runtime, avoiding the need for a full VM.

---

#### 5. **Minikube Installation Dependencies**

- **kubectl**: The command-line tool used to interact with the Kubernetes cluster. Ensure it is installed on your system.
- **Container or VM drivers**: Depending on your environment (Docker, VirtualBox, KVM, etc.), you may need to install additional drivers.

---

By ensuring that your system meets these requirements, you can seamlessly run Minikube and begin deploying and testing Kubernetes clusters locally.

### 2. **Prerequisites**
You'll need to install some required dependencies, including:
- Docker or another driver (e.g., KVM, VirtualBox).
- Kubernetes command-line tool (`kubectl`).



### 3. **Install Minikube**
Once you have Docker and `kubectl` set up, you can proceed to install Minikube:

1. Download Minikube:

   ```bash
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   ```
2. Install Minikube:

   ```bash
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

3. Verify Minikube installation:

   ```bash
   minikube version
   ```

You should see the version output confirming Minikube is installed.

### 4. **Start Minikube**

Once Minikube is installed, you can start a Kubernetes cluster.

1. **Start Minikube** (with Docker driver):

   ```bash
   minikube start --driver=docker
   ```

it will show the following:
```
minikube v1.34.0 on Ubuntu 22.04
✨  Selected the docker driver. Other choices: none, ssh
📌  Using Docker driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.45 ...
💾  Downloading Kubernetes v1.31.0 preload ...
    > preloaded-images-k8s-v18-v1...:  326.69 MiB / 326.69 MiB  100.00% 3.25 Mi
    > gcr.io/k8s-minikube/kicbase...:  487.90 MiB / 487.90 MiB  100.00% 2.73 Mi
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```
   

2. If you prefer to use a different driver like VirtualBox or KVM, install the necessary drivers and use the corresponding flag:

   - **VirtualBox**:
     ```bash
     sudo apt install -y virtualbox virtualbox-ext-pack
     minikube start --driver=virtualbox
     ```

   - **KVM** (requires KVM and libvirt installed):
     ```bash
     minikube start --driver=kvm2
     ```

3. After starting, check the status of Minikube:

   ```bash
   minikube status
   ```


minikube addons enable storage-provisioner
minikube addons enable default-storageclass

### Cluster Management with Minikube

- **Pause the cluster without affecting running applications**:
  ```bash
  minikube pause
  ```

- **Resume a paused cluster**:
  ```bash
  minikube unpause
  ```

- **Stop the running cluster**:
  ```bash
  minikube stop
  ```

- **Set a new memory limit (requires a restart)**:
  ```bash
  minikube config set memory 9001
  ```

- **View available add-ons for easy installation**:
  ```bash
  minikube addons list
  ```

- **Start a second cluster with an older Kubernetes version**:
  ```bash
  minikube start -p aged --kubernetes-version=v1.16.1
  ```

- **Delete all clusters**:
  ```bash
  minikube delete --all
  ```

---

#### **Open the Minikube Dashboard** (Optional)
Minikube provides a built-in Kubernetes dashboard to visualize cluster activities. You can access it by running:

```bash
minikube dashboard
```
**Note:** Sometimes it takes time to open.

### **Stop and Delete Minikube Cluster**

To stop the Minikube cluster:

```bash
minikube stop
```

To delete the Minikube cluster:

```bash
minikube delete
```

### Show Default Images

This command lists the container images currently available in your Minikube cluster. 

```bash
minikube image ls
```

These are the default Images:

1. **`registry.k8s.io/pause:3.10`**
   - Placeholder container for managing pod lifecycles (holds network namespace).

2. **`registry.k8s.io/kube-scheduler:v1.31.0`**
   - Responsible for assigning pods to nodes based on resource availability.

3. **`registry.k8s.io/kube-proxy:v1.31.0`**
   - Manages network rules and communication between pods and external services.

4. **`registry.k8s.io/kube-controller-manager:v1.31.0`**
   - Runs controllers for routine tasks like replication and scaling.

5. **`registry.k8s.io/kube-apiserver:v1.31.0`**
   - Hosts the API server, central management interface for the cluster.

6. **`registry.k8s.io/etcd:3.5.15-0`**
   - Distributed key-value store for cluster configuration and state.

7. **`registry.k8s.io/coredns/coredns:v1.11.1`**
   - DNS server for service discovery within the cluster.

8. **`gcr.io/k8s-minikube/storage-provisioner:v5`**
   - Manages dynamic volume provisioning for persistent storage in Minikube.

9. **`docker.io/kubernetesui/metrics-scraper:<none>`**
   - Collects metrics from the cluster (tag unspecified).

10. **`docker.io/kubernetesui/dashboard:<none>`**
    - Web-based interface for managing and monitoring Kubernetes resources (tag unspecified).

These images are crucial for the functionality and management of a Minikube Kubernetes cluster, handling core operations, networking, and service discovery.

#### Why These Images Are Available After Installation

1. **Default Components**: Minikube includes essential Kubernetes components (API server, scheduler, controller manager) to create a functional cluster.

2. **Pod Management**: The `pause` container manages pod lifecycles and holds network namespaces.

3. **Service Discovery**: CoreDNS provides DNS services for inter-service communication within the cluster.

4. **Persistent Storage**: The storage provisioner handles dynamic volume provisioning for applications.

5. **Monitoring**: Metrics scraper and dashboard images enable monitoring and management through a web interface.

6. **Simplified Setup**: Bundling these images allows for a quick and efficient setup, enabling users to start using Kubernetes without manual configuration.

The `minikube image ls` command helps you view essential container images that ensure your Minikube cluster is ready to manage Kubernetes workloads effectively.

### 8. **Additional Minikube Commands**

- **Check Minikube IP**:
  ```bash
  minikube ip
  ```

- **SSH into Minikube Node**:
  ```bash
  minikube ssh
  ```

- **View Logs**:
  ```bash
  minikube logs
  ```

### Managing Multiple Clusters with Minikube

Minikube allows you to run multiple Kubernetes clusters on the same machine using **profiles**. Each profile represents a separate cluster with its own configuration (e.g., Kubernetes version, CPU, memory).

#### Key Commands for Managing Multiple Clusters:

- **Start a Cluster with a Profile**:  
  You can create and start a new cluster with a specific profile name.
  ```bash
  minikube start -p <profile-name>
  ```
  Example:
  ```bash
  minikube start -p dev-cluster
  ```

- **Switch Between Clusters**:  
  To switch the active profile (i.e., the cluster you want to interact with).
  ```bash
  minikube profile <profile-name>
  ```

- **List All Available Profiles**:  
  View all the running and stopped clusters on your system.
  ```bash
  minikube profile list
  ```

- **Delete a Specific Cluster**:  
  Remove a cluster by deleting its profile.
  ```bash
  minikube delete -p <profile-name>
  ```

#### Use Case:  
Using multiple clusters is helpful when you need different environments (e.g., development, testing) or want to test different Kubernetes versions without interfering with your main cluster.


### Troubleshooting

- If you encounter errors related to Docker permissions, ensure you’ve added your user to the Docker group and have logged out/logged back in.
- If Minikube can’t find a driver, ensure the selected driver (Docker, KVM, VirtualBox) is installed and healthy.
