# **Implementing Local Storage for worker-node2 in Kubernetes**

In your Kubernetes cluster, `worker-node2` (IP: `192.168.1.183`) is a worker node where Pods like `calico-node-rtmcr` are scheduled. To implement local storage for this node, we’ll use the `local-path-provisioner` to dynamically provision Persistent Volumes (PVs) from a directory on `worker-node2` (e.g., `/mnt/data`). Then, we’ll ensure a Pod uses this storage by scheduling it on that specific node using `nodeName`.

---

## **1. Prerequisites**
- **Example Node**: `worker-node2` (IP: `192.168.1.183`) must be in a `Ready` state:
  ```bash
  kubectl get nodes
  # Ensure worker-node2 is listed as Ready
  ```
- **Access**: SSH access to `worker-node2` as `adminit` (or another user with sudo privileges).
- **Disk Space**: Free space on `worker-node2` for storage (e.g., `/mnt/data`).
- **kubectl**: Configured on `master-node` (or wherever you run commands).

---

## **2. Steps to Implement Local Storage**

### **Step 1: Prepare worker-node2**
Create a directory on `worker-node2` to store persistent data and set appropriate permissions.

- **SSH into worker-node2**:
  ```bash
  ssh adminit@192.168.1.183
  ```
- **Create Directory**:
  ```bash
  sudo mkdir -p /mnt/data
  sudo chmod 777 /mnt/data  # Liberal permissions for simplicity; adjust as needed
  sudo chown nobody:nobody /mnt/data  # Matches local-path-provisioner defaults
  ```
- **Verify**:
  ```bash
  ls -ld /mnt/data
  # Output: drwxrwxrwx 2 nobody nogroup ... /mnt/data
  ```
- **Exit SSH**:
  ```bash
  exit
  ```

---

### **Step 2: Install local-path-provisioner** (for making StorageClass)
Deploy the `local-path-provisioner` to enable dynamic provisioning of local storage **across your cluster**, including `worker-node2`.

- **Apply the Manifest**:
  From `master-node`:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
  ```
- **What This Does**:
  - Deploys a `StorageClass` named `local-path`.
  - Runs a provisioner Pod in the `local-path-storage` namespace.
  - Uses `/opt/local-path-provisioner` by default on each node.

- **Customize Storage Path (Optional)**:
  To use `/mnt/data` instead of the default:
  - Edit the ConfigMap:
    ```bash
    kubectl edit configmap local-path-config -n local-path-storage
    ```
    Change:
    ```yaml
    data:
      path: "/mnt/data"  # Update from /opt/local-path-provisioner
    ```
  - Restart the provisioner:
    ```bash
    kubectl rollout restart deployment local-path-provisioner -n local-path-storage
    ```

- **Verify**:
  ```bash
  kubectl get storageclass local-path
  ```

The output should be like:

  ```bash
  # Output: NAME        PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      AGE
  #         local-path  rancher.io/local-path   Delete          WaitForFirstConsumer   1m
  kubectl get pod -n local-path-storage
  # Ensure local-path-provisioner pod is Running
  ```

---

### **Step 3: Create a Persistent Volume Claim (PVC)**
Request storage that will be provisioned on `worker-node2`.

- **PVC YAML (`local-pvc.yaml`)**:
  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: worker2-pvc
    namespace: default
  spec:
    accessModes:
      - ReadWriteOnce  # Local storage supports RWO
    resources:
      requests:
        storage: 2Gi
    storageClassName: local-path
  ```
- **Apply**:
  ```bash
  kubectl apply -f local-pvc.yaml
  ```
- **Verify**:
  ```bash
  kubectl get pvc worker2-pvc
  # Output: NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
  #         worker2-pvc  Bound    pvc-<hash>                                 2Gi        RWO            local-path     1m
  ```

---

### **Step 4: Create a Pod Using the PVC on worker-node2**
Schedule a Pod on `worker-node2` and mount the PVC to test local storage.

- **Pod YAML (`worker2-pod.yaml`)**:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: worker2-storage-pod
    namespace: default
  spec:
    containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "while true; do echo 'Data from worker-node2' >> /data/message.txt; sleep 5; done"]
      volumeMounts:
      - mountPath: "/data"
        name: storage
    volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: worker2-pvc
    nodeName: worker-node2  # Forces Pod to run on worker-node2
  ```
- **Apply**:
  ```bash
  kubectl apply -f worker2-pod.yaml
  ```

- **Verify Pod**:
  ```bash
  kubectl get pod worker2-storage-pod -o wide
  # Output: NAME                 READY   STATUS    RESTARTS   AGE   IP           NODE          ...
  #         worker2-storage-pod  1/1     Running   0          1m    192.168.1.x  worker-node2
  ```

- **Test Storage**:
  ```bash
  kubectl exec -it worker2-storage-pod -- cat /data/message.txt
  # Output: Multiple lines of "Data from worker-node2"
  ```

---

### **Step 5: Test Persistence**
Ensure data persists across Pod restarts:
- Delete and recreate the Pod:
  ```bash
  kubectl delete pod worker2-storage-pod
  kubectl apply -f worker2-pod.yaml
  ```
- Check data:
  ```bash
  kubectl exec -it worker2-storage-pod -- cat /data/message.txt
  # Output: Previous "Data from worker-node2" lines remain
  ```

- **Confirm on Node**:
  SSH into `worker-node2`:
  ```bash
  ssh adminit@192.168.1.183 "ls -l /mnt/data"
  # Look for a directory like pvc-<hash> containing message.txt
  ```

---

## **3. How It Works on worker-node2**
- **Provisioning**: When `worker2-pvc` is created, `local-path-provisioner` detects the Pod’s scheduling on `worker-node2` (due to `nodeName`) and creates a PV using a subdirectory under `/mnt/data` (e.g., `/mnt/data/pvc-<hash>`).
- **Binding**: The PVC binds to this PV.
- **Mounting**: The Pod mounts the PV as a `hostPath` volume at `/data`, writing data to the node’s filesystem.

---

## **4. Best Practices for worker-node2**
- **Node-Specific Scheduling**: Use `nodeName: worker-node2` or node selectors to ensure Pods use storage on this node.
- **Disk Space**: Monitor `worker-node2`’s disk usage:
  ```bash
  ssh adminit@192.168.1.183 "df -h /mnt/data"
  ```
- **Permissions**: `chmod 777` is permissive; tighten to `755` or specific users (e.g., `nobody:nogroup`) if security matters.
- **Backup**: Copy `/mnt/data` periodically (e.g., `rsync`) since local storage isn’t replicated.

---

## **5. Troubleshooting**
- **PVC Not Binding**:
  ```bash
  kubectl describe pvc worker2-pvc
  ```
  - Ensure `local-path` StorageClass exists and provisioner is running.
- **Pod Stuck**:
  ```bash
  kubectl describe pod worker2-storage-pod
  ```
  - Check for volume mount errors or node scheduling issues.
- **No Data**:
  - Verify PV path:
    ```bash
    kubectl get pv -o yaml
    ```
  - Confirm directory on `worker-node2`:
    ```bash
    ssh adminit@192.168.1.183 "ls -l /mnt/data"
    ```

---

## **6. Example Tailored to worker-node2**
- **Full Workflow**:
  1. Prep `worker-node2`:
     ```bash
     ssh adminit@192.168.1.183 "sudo mkdir -p /mnt/data && sudo chmod 777 /mnt/data"
     ```
  2. Install provisioner:
     ```bash
     kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
     ```
  3. Apply PVC and Pod:
     ```bash
     kubectl apply -f local-pvc.yaml -f worker2-pod.yaml
     ```
  4. Test:
     ```bash
     kubectl exec -it worker2-storage-pod -- ls /data
     ```

---

## **7. Summary**
- **Local Storage**: Uses `local-path-provisioner` to provision PVs on `worker-node2`’s `/mnt/data`.
- **Steps**: Prep node, install provisioner, create PVC, deploy Pod with `nodeName`.
- **Result**: Persistent storage tied to `worker-node2` for your lab.

Let me know if you need adjustments (e.g., different directory, multi-node setup) or help with errors! 🚀
