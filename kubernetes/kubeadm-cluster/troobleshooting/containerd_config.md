Thanks for sharing your `config.toml` for containerd! I notice that this appears to be a minimal or default configuration with most sections commented out, and it has `disabled_plugins = ["cri"]`, which isn’t what we want for a Kubernetes setup with kubeadm and containerd. Kubernetes relies on the CRI (Container Runtime Interface) plugin to manage containers, so we need to enable it and configure it properly, especially with the `SystemdCgroup` setting for compatibility with kubeadm.

Let’s modify this file step-by-step to make it suitable for your Kubernetes cluster on AlmaLinux.

### Issues with Current Config
1. **`disabled_plugins = ["cri"]`**: This disables the CRI plugin, which Kubernetes needs to communicate with containerd. We need to remove or comment this line.
2. **Missing CRI Configuration**: The default config doesn’t explicitly enable the CRI plugin or set the `SystemdCgroup = true` option, which is required for Kubernetes.
3. **Commented Sections**: Most settings are commented out, so containerd is likely using built-in defaults. We’ll need to uncomment and adjust some sections.

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

### Key Changes Explained
1. **Remove `disabled_plugins`**:
   - We’ve removed `disabled_plugins = ["cri"]` to enable the CRI plugin, which Kubernetes requires.

2. **Version**:
   - Added `version = 2` to use the latest config format.

3. **Root and State**:
   - Uncommented `root` and `state` to explicitly set the default paths.

4. **CRI Plugin Configuration**:
   - Added `[plugins."io.containerd.grpc.v1.cri"]` section.
   - Set `sandbox_image` to `registry.k8s.io/pause:3.9` (Kubernetes pause container, compatible with v1.28).
   - Configured the `runc` runtime with `SystemdCgroup = true` to ensure Kubernetes can manage cgroups properly.

5. **Keep Defaults**:
   - Left `grpc` and `debug` sections mostly as defaults, uncommenting them for clarity.

### Steps to Apply
1. **Backup Current Config**:
   ```bash
   sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
   ```

2. **Replace Config**:
   Edit the file:
   ```bash
   sudo vi /etc/containerd/config.toml
   ```
   Replace its contents with the version above.

3. **Restart Containerd**:
   ```bash
   sudo systemctl restart containerd
   ```

4. **Verify**:
   Check that containerd is running:
   ```bash
   sudo systemctl status containerd
   ```
   Ensure the CRI is enabled by checking the socket:
   ```bash
   ls -l /run/containerd/containerd.sock
   ```

### Apply to All Nodes
Since you have 3 VMs (k8s-master, k8s-worker1, k8s-worker2), repeat this process on all nodes, as they all need containerd configured identically for Kubernetes.

### Kubernetes Next Steps
With this updated config:
- On the master, proceed with `kubeadm init` (if not already done):
  ```bash
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/containerd/containerd.sock
  ```
- On workers, use the join command with the `--cri-socket` flag as shown earlier.

### Troubleshooting
- If containerd fails to start, check logs:
  ```bash
  journalctl -u containerd
  ```
- Verify CRI is working:
  ```bash
  sudo ctr plugin ls | grep cri
  ```
  Should show `io.containerd.grpc.v1.cri` as active, not disabled.

This config should now work seamlessly with your Kubernetes setup. Let me know if you hit any snags! 🚀
