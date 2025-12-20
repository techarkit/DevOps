# Advanced Minikube Features

### 1. **Understanding the Default Minikube Start Process**
The `minikube start` command initiates a default single-node Kubernetes cluster, deploying it in a VM or container environment using a selected isolation driver (such as VirtualBox or Docker). By default, Minikube provisions a VM with the following hardware specs:
- **CPUs**: 2
- **Memory**: 6 GB
- **Disk**: 20 GB

Minikube also installs the latest Kubernetes version and the Docker runtime to manage containerized applications. This cluster configuration is stored in a **profile**, which allows restarting and managing the cluster efficiently.

### 2. **Profiles in Minikube**
Minikube's **profile** feature is used to manage multiple clusters with different configurations. A profile is a stored object containing the specifications of a cluster, such as the driver, Kubernetes version, container runtime, and hardware resources.

You can list all available profiles with:

```bash
$ minikube profile list
```

Example output for a single default profile:

| Profile  | VM Driver  | Runtime |       IP       | Port | Version | Status  | Nodes | Active |
|----------|------------|---------|----------------|------|---------|---------|-------|--------|
| minikube | virtualbox | docker  | 192.168.59.100 | 8443 | v1.28.3 | Running |     1 | *      |

### 3. **Creating Custom Clusters with Profiles**
Minikube allows the creation of customized clusters with specific drivers, Kubernetes versions, container runtimes, and node configurations. This is done using the `--profile` or `-p` flag in combination with other options like the Kubernetes version, driver, number of nodes, and networking.

#### Examples of Custom Clusters:
1. **Custom Podman Cluster**:
   ```bash
   $ minikube start --kubernetes-version=v1.27.10 \
     --driver=podman --profile minipod
   ```

2. **Multi-Node Docker Cluster**:
   ```bash
   $ minikube start --nodes=2 --kubernetes-version=v1.28.1 \
     --driver=docker --profile doubledocker
   ```

3. **Multi-Node VirtualBox Cluster**:
   ```bash
   $ minikube start --driver=virtualbox --nodes=3 --disk-size=10g \
     --cpus=2 --memory=6g --kubernetes-version=v1.27.12 --cni=calico \
     --container-runtime=cri-o -p multivbox
   ```

4. **Large Docker Cluster**:
   ```bash
   $ minikube start --driver=docker --cpus=6 --memory=8g \
     --kubernetes-version="1.27.12" -p largedock
   ```

5. **Containerd VirtualBox Cluster**:
   ```bash
   $ minikube start --driver=virtualbox -n 3 --container-runtime=containerd \
     --cni=calico -p minibox
   ```

### 4. **Managing Multiple Profiles**
When multiple profiles are created, you can switch between them using the `minikube profile` command. For example:

1. **List all profiles**:
   ```bash
   $ minikube profile list
   ```

Example output for multiple profiles:

| Profile  | VM Driver  | Runtime |       IP       | Port | Version | Status  | Nodes | Active |
|----------|------------|---------|----------------|------|---------|---------|-------|--------|
| minibox  | virtualbox | cri-o   | 192.168.59.101 | 8443 | v1.25.3 | Running |     3 |        |
| minikube | virtualbox | docker  | 192.168.59.100 | 8443 | v1.25.3 | Running |     1 | *      |

2. **Switch to a specific profile (e.g., minibox)**:
   ```bash
   $ minikube profile minibox
   ```

3. **Switch back to the default profile**:
   ```bash
   $ minikube profile minikube
   ```
   Or:
   ```bash
   $ minikube profile default
   ```

### 5. **Summary**
Minikube's advanced features, such as **profiles**, enable users to manage multiple Kubernetes clusters with different configurations from a single command-line tool. This flexibility allows users to easily create, configure, and manage reusable clusters tailored to specific use cases, leveraging different drivers, runtimes, and Kubernetes versions.

### Minikube Profiles:

Minikube offers profile awareness in most commands, allowing users to easily manage multiple clusters by specifying the profile name. The default `minikube` cluster is managed without requiring an explicit profile name, while custom clusters are explicitly referenced. Here's how you can stop and restart clusters:

#### Managing Multiple Clusters:
Stopping and starting the `minibox` cluster and the default `minikube` cluster:

```bash
# Stop the 'minibox' cluster explicitly
$ minikube stop -p minibox

# Start the 'minibox' cluster explicitly
$ minikube start -p minibox

# Stop the default 'minikube' cluster implicitly
$ minikube stop

# Start the default 'minikube' cluster implicitly
$ minikube start
```

#### Useful Minikube Commands:

- **Check Minikube Version**:
  Display the currently installed Minikube version:
  ```bash
  $ minikube version
  
  minikube version: v1.32.0
  commit: 8220a6eb95f0a4d75f7f2d7b14cef975f050512d
  ```

- **Enabling Command Auto-Completion**:
  Minikube supports auto-completion in your terminal, which is helpful for quickly filling in commands using the `TAB` key. To enable completion for the `bash` shell in Ubuntu, follow these steps:
  ```bash
  # Install bash completion if not installed
  $ sudo apt install bash-completion
  
  # Enable bash completion in the current shell
  $ source /etc/bash_completion
  
  # Enable minikube auto-completion
  $ source <(minikube completion bash)
  ```

- **Node Management**:
  Use the `minikube node` command to manage individual nodes of a cluster. This command lets you list nodes, add control plane or worker nodes, and start/stop/delete specific nodes.
  
  - **List Nodes**:
    You can list nodes of the default or a custom cluster:
    ```bash
    # List nodes of the default cluster
    $ minikube node list
    
    minikube 192.168.59.100
    
    # List nodes of the 'minibox' cluster
    $ minikube node list -p minibox
    
    minibox      192.168.59.101
    minibox-m02  192.168.59.102
    minibox-m03  192.168.59.103
    ```

  - **Get Node IP Address**:
    Get the IP address of a cluster’s control plane node, or other nodes by specifying node names:
    ```bash
    # IP of the default 'minikube' cluster's control plane node
    $ minikube ip
    
    192.168.59.100
    
    # IP of the 'minibox' cluster's control plane node
    $ minikube -p minibox ip
    
    192.168.59.101
    
    # IP of a worker node in the 'minibox' cluster
    $ minikube -p minibox ip -n minibox-m02
    
    192.168.59.102
    ```

- **Deleting Clusters**:
  When a cluster is no longer needed, you can delete it with the `minikube delete` command. By default, this command will delete the default `minikube` cluster, but you can specify a profile to delete custom clusters.
  
  - **Delete the Default Cluster**:
    ```bash
    $ minikube delete
    
    🔥  Deleting "minikube" in virtualbox ...
    💀  Removed all traces of the "minikube" cluster.
    ```
  
  - **Delete a Custom Cluster**:
    ```bash
    $ minikube delete -p minibox
    
    🔥  Deleting "minibox" in virtualbox ...
    🔥  Deleting "minibox-m02" in virtualbox ...
    🔥  Deleting "minibox-m03" in virtualbox ...
    💀  Removed all traces of the "minibox" cluster.
    ```

Minikube’s flexibility with profiles allows users to manage various clusters, customize them as needed, and optimize resources for development environments. This makes it an essential tool for Kubernetes practitioners, especially in environments where rapid cluster setup and teardown are required.
