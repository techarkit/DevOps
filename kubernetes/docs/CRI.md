## CRI (A Container Runtime)

https://medium.com/@lexitrainerph/container-runtime-interface-cri-navigating-from-basics-to-expertise-ff5764048f31

https://www.cloudraft.io/blog/container-runtimes

**Container Runtime Interface (CRI)**

The Container Runtime Interface (CRI) is a plugin interface for container runtimes to integrate with Kubernetes. The CRI standardizes how Kubernetes interacts with container runtimes, which is essential for managing containerized applications. Introduced in Kubernetes version 1.5, CRI allows Kubernetes to support multiple container runtimes, enabling flexibility and innovation in the container ecosystem.

### Key Concepts

1. **Container Runtime**: 
   A container runtime is a software that is responsible for running containers on a host system. It provides the necessary features for container execution, including process isolation, resource management, and network configuration. Examples of container runtimes include Docker, containerd, and CRI-O.

2. **Kubelet**: 
   The Kubelet is the primary "node agent" in Kubernetes. It communicates with the container runtime through CRI to manage the containers running on each node.

3. **gRPC Protocol**: 
   CRI is based on the gRPC (Google Remote Procedure Call) protocol, which allows the Kubelet to communicate efficiently with container runtimes over network calls. This interaction is defined by Protocol Buffers (protobuf), making it fast and language-neutral.

4. **Image and Runtime Services**: 
   CRI defines two main services that a container runtime must implement:
   - **Image Service**: Responsible for pulling, managing, and removing container images.
   - **Runtime Service**: Manages the lifecycle of the containers (e.g., creating, starting, stopping containers) and pod sandboxes.

### Benefits of CRI

- **Decouples Kubernetes from a specific container runtime**: Prior to CRI, Kubernetes had a tight dependency on Docker as the default container runtime. With CRI, Kubernetes can interact with any compliant container runtime, enhancing flexibility.
  
- **Supports multiple container runtimes**: Kubernetes can now support alternatives like `containerd`, `CRI-O`, `gVisor`, and more.

- **Innovation and performance optimization**: By providing an open interface, CRI encourages innovation in the container runtime ecosystem without requiring changes to Kubernetes itself.

### How CRI Works

1. **Kubelet requests**:
   - The Kubelet interacts with the CRI via gRPC calls. For example, when a pod is scheduled to run, the Kubelet sends requests to the runtime service to pull images, create containers, and manage container lifecycles.

2. **Pod Sandbox**:
   - The pod sandbox is an abstraction for a pod, which is a group of containers that share the same network namespace. The CRI manages the pod sandbox by isolating the pod's network and ensuring security between pods.

3. **Container Lifecycle**:
   - CRI handles container lifecycles such as `CreateContainer`, `StartContainer`, `StopContainer`, and `RemoveContainer`. These operations are essential for ensuring that containers are created, started, and managed according to the pod specification.

### Container Runtimes Supporting CRI

Several container runtimes support CRI, including:

1. **containerd**: 
   - Developed as part of Docker, `containerd` is a lightweight runtime that is often used in Kubernetes clusters for its simplicity and performance. It manages image pulling, container execution, and networking.

2. **CRI-O**: 
   - A lightweight alternative runtime developed specifically for Kubernetes. CRI-O provides an implementation of CRI using the Open Container Initiative (OCI) standards.

3. **gVisor**: 
   - A sandboxed container runtime providing strong security by isolating container workloads from the host system.

4. **Kata Containers**: 
   - An OCI-compliant runtime that uses lightweight virtual machines for enhanced isolation between containers and the host.

### CRI Components

The CRI has several important components that work together to provide container runtime functionality:

1. **PodSandbox**: 
   - A high-level abstraction representing a pod in Kubernetes. It includes the pod's network configuration and namespaces. The sandbox provides the networking isolation for the containers within a pod.

2. **Image Service API**:
   - The image service is responsible for pulling images from a container registry, managing them on the node, and removing unused images.

3. **Runtime Service API**:
   - Manages the lifecycle of containers within a pod, such as creating, starting, stopping, and removing containers. It also handles resource management, such as CPU and memory allocation.

### CRI APIs

The CRI defines the following APIs:

1. **RunPodSandbox**: Creates a pod-level network namespace and other shared resources.
   
2. **StopPodSandbox**: Stops all containers in a pod and releases associated resources.
   
3. **RemovePodSandbox**: Removes the sandbox after it has stopped.
   
4. **ListContainers**: Lists containers managed by the runtime.

5. **Image-related APIs**:
   - **PullImage**: Pulls an image from a container registry.
   - **ListImages**: Lists images available on the node.
   - **RemoveImage**: Removes an image from the node.

### CRI vs. Docker

While Docker was historically the default runtime for Kubernetes, CRI enables Kubernetes to use multiple runtimes:

- **Docker’s CRI Support**: Docker used to work as the default runtime in Kubernetes via an integration called `dockershim`, which implemented the CRI. However, Kubernetes deprecated `dockershim` in Kubernetes v1.20 and removed it in v1.24, encouraging users to transition to other CRI-compliant runtimes like `containerd` or `CRI-O`.

- **Why Kubernetes Moved Away from Docker**:
   - Docker is not just a container runtime but also includes other components like Docker CLI, Docker Engine, and orchestration features. Kubernetes doesn't require all these additional functionalities and prefers lightweight runtimes that strictly adhere to OCI standards.

### CRI's Role in Kubernetes Ecosystem

1. **Flexibility**: 
   - CRI abstracts the runtime layer in Kubernetes, making it possible to switch between different runtimes seamlessly. This allows Kubernetes to evolve independently of container runtime technologies.

2. **Security**:
   - Different runtimes offer different security features. For example, gVisor and Kata Containers focus on providing enhanced isolation for workloads, addressing concerns for running untrusted or multi-tenant workloads.

3. **Performance**:
   - Certain runtimes like containerd are optimized for performance, reducing overhead and startup time, which benefits large-scale Kubernetes deployments.

### CRI-O Example: Setting up CRI-O with Kubernetes

Here’s an example of how to set up `CRI-O` as the runtime for Kubernetes:

1. **Install CRI-O**:
   ```bash
   sudo apt update
   sudo apt install cri-o cri-o-runc
   ```

2. **Enable and start CRI-O**:
   ```bash
   sudo systemctl enable crio
   sudo systemctl start crio
   ```

3. **Configure Kubelet to use CRI-O**:
   In your `kubelet` configuration, specify CRI-O as the container runtime:
   ```bash
   KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///var/run/crio/crio.sock
   ```

4. **Restart Kubelet**:
   ```bash
   sudo systemctl restart kubelet
   ```

### Conclusion

The Container Runtime Interface (CRI) is a critical component of Kubernetes that abstracts the container runtime layer, enabling flexibility in container execution. It decouples Kubernetes from Docker, encouraging the use of lightweight, optimized runtimes such as `containerd` and `CRI-O`. CRI allows for innovation in container runtimes while ensuring that Kubernetes can manage containers efficiently and securely across diverse environments.
