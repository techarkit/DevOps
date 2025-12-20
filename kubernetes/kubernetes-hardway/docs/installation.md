# Kubernetes Installation - Hard Way

This document provides detailed instructions for installing Kubernetes using the "hard way" method. This approach involves manually setting up each component of the Kubernetes cluster, allowing for a deeper understanding of how Kubernetes operates.

## Prerequisites

Before you begin the installation process, ensure you have the following:

1. **Operating System**: A Linux-based OS (Ubuntu, CentOS, etc.)
2. **Hardware Requirements**: 
   - At least 2 GB of RAM per machine (more is recommended)
   - 2 CPUs per machine
   - Sufficient disk space
3. **Software Requirements**:
   - `curl`
   - `git`
   - `docker`
   - `kubectl`
   - `kubelet`
   - `kubeadm`
4. **Networking**: Ensure that all machines can communicate with each other over the network.
5. **SSH Access**: You should have SSH access to all machines in the cluster.

## Step-by-Step Installation Process

### Step 1: Set Up the Environment

1. **Prepare the Machines**: Set up your machines with the required OS and install necessary packages.
2. **Disable Swap**: Kubernetes requires that swap be disabled. Run the following command on each machine:
   ```
   sudo swapoff -a
   ```

### Step 2: Install Docker

1. **Install Docker**: Follow the official Docker installation guide for your OS.
2. **Start Docker**: Ensure Docker is running:
   ```
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

### Step 3: Install Kubernetes Components

1. **Install `kubelet`, `kubeadm`, and `kubectl`**:
   ```
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   ```

### Step 4: Initialize the Kubernetes Control Plane

1. **Run `kubeadm init`**: On the master node, initialize the cluster:
   ```
   sudo kubeadm init --pod-network-cidr=10.244.0.0/16
   ```
2. **Set Up `kubectl` for the Regular User**:
   ```
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

### Step 5: Install a Pod Network Add-on

1. **Choose a Pod Network Add-on**: For example, Flannel or Calico.
2. **Install Flannel**:
   ```
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel.yml
   ```

### Step 6: Join Worker Nodes to the Cluster

1. **Run the Join Command**: On each worker node, run the command provided at the end of the `kubeadm init` output on the master node.

### Step 7: Verify the Installation

1. **Check Node Status**:
   ```
   kubectl get nodes
   ```

## Configuration Details

- Ensure that your firewall settings allow traffic on the necessary ports for Kubernetes.
- Configure any additional settings as required for your specific environment.

## Required Ports

### Control Plane Node(s)
- TCP 6443: Kubernetes API Server
- TCP 2379-2380: etcd server client API
- TCP 10250: Kubelet API
- TCP 10259: kube-scheduler
- TCP 10257: kube-controller-manager

### Worker Node(s)
- TCP 10250: Kubelet API
- TCP 30000-32767: NodePort Services

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)
- [Kubernetes GitHub Repository](https://github.com/kubernetes/kubernetes)

This guide provides a comprehensive overview of the manual installation of Kubernetes. Follow each step carefully to ensure a successful setup.