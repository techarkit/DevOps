# cgroup Drivers in Linux

## Overview
Control groups (cgroups) in Linux are used to allocate and constrain system resources such as CPU and memory for processes. In Kubernetes, both the **kubelet** and the **container runtime** interact with cgroups to enforce resource limits and requests for pods and containers.

To manage cgroups, Kubernetes components must use a **cgroup driver**. It is crucial that both the **kubelet** and the **container runtime** use the same cgroup driver to avoid inconsistencies and potential system instability.

## Available cgroup Drivers
There are two primary cgroup drivers in Kubernetes:

1. **cgroupfs**
2. **systemd**

### 1. cgroupfs Driver
- **Default driver** in the kubelet.
- Directly interfaces with the **cgroup filesystem** to configure and manage cgroups.
- Works well in environments where **systemd is not the init system**.
- **Not recommended** for distributions where systemd is the init system because systemd expects to be the sole cgroup manager.
- **With cgroup v2**, using systemd is strongly recommended over cgroupfs.

### 2. systemd cgroup Driver
- Uses **systemd** as the cgroup manager.
- When systemd is the init system, it manages the root cgroup and allocates cgroups per systemd unit.
- **Recommended** for systems using **systemd** as the init system to avoid conflicts between multiple cgroup managers.
- Provides better **resource isolation and stability** under resource pressure.
- **Default in kubeadm** starting from Kubernetes **v1.22**.

## Configuring systemd as the cgroup Driver
If **systemd** is the init system, it is advisable to configure Kubernetes components to use the **systemd cgroup driver**.

### Updating Kubelet Configuration
Edit the kubelet configuration file and set `cgroupDriver` to `systemd`:

```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
...
cgroupDriver: systemd
```

### Configuring the Container Runtime
If using **systemd** as the cgroup driver for the kubelet, the container runtime must also be configured to use **systemd**:
- **containerd**: Refer to its configuration guide.
- **CRI-O**: Adjust its settings accordingly.

## Kubernetes 1.32: Automatic cgroup Driver Detection
In Kubernetes **1.32**, with the `KubeletCgroupDriverFromCRI` feature gate enabled and a compatible container runtime (supporting `RuntimeConfig CRI RPC`),
- The **kubelet automatically detects** the correct cgroup driver from the runtime.
- The `cgroupDriver` setting in kubelet configuration is **ignored**.

## Caution: Changing cgroup Driver on an Existing Node
- Changing the cgroup driver of a node that is already part of a cluster can cause errors.
- Pods created with one cgroup driver might **fail to restart** under a different driver.
- If feasible, **replace the node** or **reinstall it with automation** rather than manually changing the cgroup driver.

## Migrating to systemd in kubeadm Managed Clusters
If you need to migrate an existing kubeadm-managed cluster to **systemd**, follow the official Kubernetes documentation on **configuring a cgroup driver**.

---
By ensuring that both the **kubelet** and **container runtime** use the same cgroup driver, Kubernetes administrators can improve system stability, resource management, and overall performance.

