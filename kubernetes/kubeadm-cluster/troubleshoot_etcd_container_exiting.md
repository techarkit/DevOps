The `etcd.yaml` manifest looks mostly standard for a single-node Kubernetes cluster deployed with `kubeadm`, but the `etcd` logs and its repeated termination (SIGTERM) suggest an issue with the health probes or resource constraints. Let’s analyze the relevant sections and propose a fix.

---

### Key Sections of `etcd.yaml`

1. **Liveness Probe**:
   ```yaml
   livenessProbe:
     failureThreshold: 8
     httpGet:
       host: 127.0.0.1
       path: /livez
       port: 2381
       scheme: HTTP
     initialDelaySeconds: 10
     periodSeconds: 10
     timeoutSeconds: 15
   ```
   - Checks `http://127.0.0.1:2381/livez` every 10 seconds, starting after 10 seconds, with a 15-second timeout.
   - Fails after 8 attempts (80 seconds total).

2. **Readiness Probe**:
   ```yaml
   readinessProbe:
     failureThreshold: 3
     httpGet:
       host: 127.0.0.1
       path: /readyz
       port: 2381
       scheme: HTTP
     periodSeconds: 1
     timeoutSeconds: 15
   ```
   - Checks `http://127.0.0.1:2381/readyz` every second, with a 15-second timeout.
   - Fails after 3 attempts (3 seconds total).

3. **Startup Probe**:
   ```yaml
   startupProbe:
     failureThreshold: 24
     httpGet:
       host: 127.0.0.1
       path: /readyz
       port: 2381
       scheme: HTTP
     initialDelaySeconds: 10
     periodSeconds: 10
     timeoutSeconds: 15
   ```
   - Checks `http://127.0.0.1:2381/readyz` every 10 seconds, starting after 10 seconds, with a 15-second timeout.
   - Fails after 24 attempts (240 seconds total).

4. **Resources**:
   ```yaml
   resources:
     requests:
       cpu: 100m
       memory: 100Mi
   ```
   - Requests 100m CPU (0.1 core) and 100MiB memory.
   - No limits are set, so `etcd` could theoretically consume more if available.

5. **Command**:
   - Matches the `etcd` logs you provided, with `--listen-metrics-urls=http://127.0.0.1:2381` enabling the metrics endpoint used by the probes.

---

### Analysis
- **Probe Configuration**:
  - The probes target `http://127.0.0.1:2381`, which aligns with `--listen-metrics-urls=http://127.0.0.1:2381` in the `etcd` command.
  - From the logs, `etcd` starts serving at `08:10:30.577614Z` and shuts down at `08:10:43.261631Z` (13 seconds later) due to a SIGTERM.
  - The startup probe allows 240 seconds before failing, and the liveness probe allows 80 seconds—yet `etcd` is terminated after only 13 seconds. This suggests the SIGTERM isn’t from probe failure but possibly from the `kubelet` or container runtime.

- **Resource Usage**:
  - The request of 100m CPU and 100Mi memory is minimal. If the node is under heavy load, `etcd` might not get enough resources to start properly, causing delays or failures in responding to probes.

- **Logs Insight**:
  - `etcd` starts successfully, becomes the Raft leader, and serves client traffic (`08:10:30.577570Z`). There’s no internal error before the SIGTERM at `08:10:43`.
  - The `kubelet` likely killed it (as seen in prior logs: `CrashLoopBackOff`), but the exact reason isn’t clear from the `etcd` logs alone.

---

### Root Cause Hypothesis
- **Probe Timing Issue**: The readiness probe (`periodSeconds: 1`, `failureThreshold: 3`) is aggressive, checking every second and failing after 3 seconds. If `etcd` isn’t fully ready by `08:10:33` (3 seconds after `08:10:30`), the `kubelet` might mark it unhealthy and terminate it, even though the startup probe hasn’t exhausted its 240-second window yet.
- **Resource Contention**: The node might be resource-constrained, delaying `etcd`’s initialization and causing probe failures.
- **Kubelet Bug/Misconfiguration**: The `kubelet` might be misinterpreting the pod state or prematurely terminating it.

---

### Resolution Steps

#### 1. Adjust Probes
Relax the readiness probe to give `etcd` more time to stabilize:
- Edit `/etc/kubernetes/manifests/etcd.yaml` (backup first: `sudo cp /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests/etcd.yaml.bak`):
  ```yaml
  readinessProbe:
    failureThreshold: 3
    httpGet:
      host: 127.0.0.1
      path: /readyz
      port: 2381
      scheme: HTTP
    periodSeconds: 10  # Change from 1 to 10
    timeoutSeconds: 15
  ```
- Increase `initialDelaySeconds` on the liveness probe:
  ```yaml
  livenessProbe:
    failureThreshold: 8
    httpGet:
      host: 127.0.0.1
      path: /livez
      port: 2381
      scheme: HTTP
    initialDelaySeconds: 30  # Change from 10 to 30
    periodSeconds: 10
    timeoutSeconds: 15
  ```

#### 2. Increase Resources
Ensure `etcd` has enough resources:
- Update the `resources` section:
  ```yaml
  resources:
    requests:
      cpu: 200m  # Increase from 100m
      memory: 256Mi  # Increase from 100Mi
    limits:
      cpu: 500m  # Add a reasonable limit
      memory: 512Mi
  ```

#### 3. Apply Changes and Restart
- Save the modified `etcd.yaml`.
- Restart the `kubelet` to reload the manifest:
  ```bash
  sudo systemctl restart kubelet
  ```
- Monitor the new `etcd` container:
  ```bash
  sudo crictl ps -a | grep etcd
  ```

#### 4. Check Logs
If it still crashes, get the new container ID and logs:
```bash
sudo crictl logs <new-etcd-container-id>
```
Also, check `kubelet` logs for termination reasons:
```bash
sudo journalctl -u kubelet | grep etcd | tail -n 20
```

#### 5. Verify Resource Availability
Confirm the node has capacity:
```bash
free -m
df -h
top
```
- Ensure memory > 512Mi free, disk space on `/var/lib/etcd` isn’t full, and CPU isn’t maxed out.

#### 6. Test Cluster
If `etcd` stabilizes:
```bash
sudo crictl ps -a  # Check if kube-apiserver is running
kubectl get pods -n kube-system
```

---

### Likely Fix
The aggressive readiness probe (`periodSeconds: 1`) is likely causing premature termination. Update it to `periodSeconds: 10`, increase resources, and restart:
```bash
sudo vi /etc/kubernetes/manifests/etcd.yaml  # Make the changes above
sudo systemctl restart kubelet
sudo crictl ps -a
```

---

### Next Steps
1. Apply the probe and resource changes as outlined.
2. Share the new `crictl ps -a` output and `etcd` logs if it still fails.
3. Provide the output of `free -m` and `df -h` to rule out resource issues.
Let me know how it goes!
