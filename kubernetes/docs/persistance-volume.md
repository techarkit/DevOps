In Kubernetes, **PV (Persistent Volume)**, **PVC (Persistent Volume Claim)**, and **StorageClass** are key components used to manage persistent storage for applications running in a cluster. These components enable Kubernetes to dynamically allocate and manage storage, ensuring data persistence even when containers are deleted or moved.

### 1. **PV (Persistent Volume)**
- A **Persistent Volume (PV)** is a piece of storage in the Kubernetes cluster that has been provisioned by an administrator or dynamically provisioned using a **StorageClass**.
- It is a **cluster resource** that is abstracted from the physical storage. PVs can represent various storage types, such as:
  - Local disk
  - NFS (Network File System)
  - Cloud-based storage (e.g., AWS EBS, Google Cloud Persistent Disks)
- A PV exists independently of the pod that uses it. This means data stored on a PV remains available even if the pod using it is deleted.

#### Example of a PV YAML:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /mnt/data
    server: 192.168.1.100
```

- **capacity**: Defines the amount of storage (e.g., 10Gi).
- **accessModes**: Specifies how the volume can be accessed (e.g., `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`).
- **persistentVolumeReclaimPolicy**: Defines what happens when the PVC bound to this PV is deleted. It can be `Retain`, `Recycle`, or `Delete`.
- **nfs**: Defines the type of storage; in this case, it's using NFS.

### 2. **PVC (Persistent Volume Claim)**
- A **Persistent Volume Claim (PVC)** is a **request for storage** by a user. It specifies the amount of storage, access mode, and sometimes the storage class the user needs.
- PVCs are used by pods to **request storage** from the cluster. Kubernetes finds a matching PV that satisfies the claim's requirements (like storage size and access mode).
- A **PVC binds to a PV** when a match is found, meaning that the application using the PVC will be bound to a specific storage resource.

#### Example of a PVC YAML:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

- **accessModes**: Specifies the access mode required by the PVC.
- **resources.requests.storage**: Defines the storage capacity requested (e.g., 5Gi).

### 3. **StorageClass**
- A **StorageClass** defines the types of storage (e.g., SSD, HDD) available to dynamically provision **Persistent Volumes** in Kubernetes.
- It allows for **dynamic provisioning** of storage resources. Instead of statically creating PVs, Kubernetes can create PVs on demand based on the specifications in the StorageClass when a PVC is created.
- **StorageClass** is often used with cloud providers (e.g., AWS, GCP, Azure) or dynamic storage backends (e.g., Ceph, GlusterFS).
  
#### Example of a StorageClass YAML:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
```

- **provisioner**: Specifies the storage backend that should dynamically provision the PV (e.g., AWS EBS in this case).
- **parameters**: Defines specific parameters for the storage (e.g., `type: gp2` refers to general-purpose SSDs in AWS).

### How They Work Together:
1. **StorageClass** defines the rules for dynamically provisioning storage.
2. When an application (pod) needs storage, it creates a **PVC** specifying the size, access mode, and optional storage class.
3. Kubernetes finds or dynamically provisions a **PV** that matches the PVC request.
4. The PV is then **bound** to the PVC.
5. The application pod can now mount the PVC and access the storage.

### Flow Example:

- A **pod** requests persistent storage by using a **PVC**.
- The PVC is matched with an existing **PV**, or a **StorageClass** dynamically provisions a new **PV**.
- The pod then uses the PVC to access the storage provided by the bound PV.

This system makes Kubernetes flexible for handling dynamic storage needs for stateful applications like databases, ensuring that data persists even if a pod restarts.

---

# Create PV Manually

To manually create **Persistent Volumes (PV)** in a Kubernetes cluster set up with `kubeadm`, follow these steps. In this guide, you'll learn how to create both **Persistent Volumes (PVs)** and **Persistent Volume Claims (PVCs)** without dynamic provisioning, using static provisioning where you define storage manually.

### Prerequisites:
- You need a running Kubernetes cluster created using `kubeadm`.
- Ensure you have access to the Kubernetes cluster (using `kubectl`).

### Steps to Manually Create Persistent Volumes:

#### Step 1: Define a Persistent Volume (PV)
1. Choose the type of storage you want to use. Common options include:
   - **HostPath**: Suitable for testing and local environments (not recommended for production).
   - **NFS**: If you have an NFS server, it’s suitable for shared storage.
   - **Local storage**: A local disk that can be mounted directly.


- **HostPath**:
  - Mounts a directory or file from the node's filesystem into a pod.
  - **Suitable for testing or local development** but **not recommended for production**.
  - Ties the pod to a specific node, making data unavailable if the pod is rescheduled elsewhere.
  - No redundancy or failover support.

- **Local Storage**:
  - Utilizes a local disk attached to a specific node.
  - **Production-ready** with node affinity, where Kubernetes manages pod scheduling to ensure the pod is placed on the node with the local disk.
  - Suitable for applications requiring **high performance and low latency** (e.g., databases).
  - Data is persistent but tied to the node; requires recovery strategies for node failure.

In short, **HostPath** is for temporary, non-production scenarios, while **Local Storage** offers persistence and performance for specific production workloads tied to local nodes.


Here's an example using **HostPath**. This is the easiest way to create a local persistent volume on a Kubernetes node.

#### Example of a HostPath-based PV YAML:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
  persistentVolumeReclaimPolicy: Retain
```

- **capacity.storage**: Specifies the size of the storage (10Gi in this case).
- **accessModes**: Defines how the storage can be accessed:
  - `ReadWriteOnce` (RWO): Only one pod can mount the volume for reading and writing.
  - `ReadOnlyMany` (ROX): Multiple pods can mount the volume for reading.
  - `ReadWriteMany` (RWX): Multiple pods can mount the volume for both reading and writing.
- **hostPath**: Specifies a path on the node's filesystem (e.g., `/mnt/data`).
- **persistentVolumeReclaimPolicy**: Defines what happens when a PVC is deleted. `Retain` will keep the data on the PV after it is released.

2. Create the PV in your cluster:

```bash
kubectl apply -f pv.yaml
```

You can verify the PV was created by running:

```bash
kubectl get pv
```
---

#### Example of a Local Storage-based PV YAML:

You'll need to follow several steps to manually set up **local storage** as a **Persistent Volume (PV)** and bind it to a **Persistent Volume Claim (PVC)**. Here's how you can do it:

### Steps to Set Up Local Storage:

#### 1. **Prepare Local Storage Directory on the Node**
You'll need to create a directory on your Kubernetes node that will act as the storage for the persistent volume.

On your node (where Minikube is running or on any node in your kubeadm cluster):
```bash
sudo mkdir -p /mnt/disks/ssd1
sudo chmod 777 /mnt/disks/ssd1  # Set appropriate permissions
```
This path (`/mnt/disks/ssd1`) will be used for the local storage.

#### 2. **Create a Persistent Volume (PV) YAML**
Create a YAML file (`local-pv.yaml`) to define the local storage as a Persistent Volume.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 100Gi               # Size of the volume
  accessModes:
    - ReadWriteOnce              # Access mode for the volume
  persistentVolumeReclaimPolicy: Retain  # Retain data even after PVC is deleted
  storageClassName: local-storage        # Define a custom storage class
  local:
    path: /mnt/disks/ssd1         # Path to the local disk directory on the node
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - <your-node-name>  # Replace with the actual node name where the PV is located
```

- **storageClassName**: Defines a custom storage class (`local-storage`) for local volumes.
- **nodeAffinity**: Specifies the node where this local storage volume resides (replace `<your-node-name>` with the actual hostname of your node).

You can get the node name by running:
```bash
kubectl get nodes
```

#### 3. **Apply the Persistent Volume YAML**
Apply the `local-pv.yaml` file to create the Persistent Volume.

```bash
kubectl apply -f local-pv.yaml
```

Verify the Persistent Volume is created:
```bash
kubectl get pv
```

#### 4. **Create a Persistent Volume Claim (PVC) YAML**
Now create a PVC that will request storage from the PV you just created. Create another file (`local-pvc.yaml`):

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  storageClassName: local-storage   # Must match the storage class of the PV
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi                # Request a portion of the PV's storage
```

#### 5. **Apply the Persistent Volume Claim YAML**
Apply the PVC to claim storage from the local PV.

```bash
kubectl apply -f local-pvc.yaml
```

Verify the PVC is bound to the PV:
```bash
kubectl get pvc
```

#### 6. **Use the Persistent Volume in a Pod**
Once the PVC is successfully bound to the PV, you can use it in a Pod. Here's an example Pod definition (`local-pod.yaml`) that uses the PVC:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: local-storage-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: "/mnt/storage"
      name: local-storage
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: local-pvc
```

Apply the Pod definition:
```bash
kubectl apply -f local-pod.yaml
```

This Pod will mount the local storage at `/mnt/storage` inside the container.

#### 7. **Verify the Setup**
Check that the Pod is running:
```bash
kubectl get pods
```

You can also verify that the local storage is mounted correctly by logging into the Pod and checking the mounted volume:

```bash
kubectl exec -it local-storage-pod -- /bin/sh
```

Inside the container, you can navigate to `/mnt/storage` to see your mounted storage.

---

### Key Notes:
- **Node Affinity**: Since this is local storage, the pod can only run on the node where the local PV exists.
- **Persistent Volume Reclaim Policy**: The reclaim policy `Retain` ensures that even if the PVC is deleted, the data in the PV is retained.
- **StorageClass**: Use a custom `local-storage` StorageClass to differentiate this local PV from other cloud or network storage.

This setup makes local storage usable in a Kubernetes environment, even on a single node like Minikube or in a kubeadm cluster.

---
#### Step 2: Define a Persistent Volume Claim (PVC)
The **Persistent Volume Claim (PVC)** is what your application (or pod) will use to request storage.

#### Example of a PVC YAML:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

- **accessModes**: This should match the access mode specified in the PV (`ReadWriteOnce` in this case).
- **resources.requests.storage**: This should be less than or equal to the capacity specified in the PV.

3. Create the PVC in your cluster:

```bash
kubectl apply -f pvc.yaml
```

To verify the PVC was created and bound to the PV:

```bash
kubectl get pvc
```

You should see that the PVC is **Bound** to the PV if the request matches the available PV.

#### Step 3: Use the PVC in a Pod
Once the PVC is created and bound to a PV, you can use it in a pod. Here's an example of how to mount the PVC into a pod.

#### Example Pod Using the PVC:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pv-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: local-pvc
```

- **volumeMounts**: This specifies where in the container’s filesystem the storage will be mounted (`/usr/share/nginx/html` in this case).
- **volumes.persistentVolumeClaim.claimName**: Specifies the PVC that the pod will use.

4. Apply the pod definition:

```bash
kubectl apply -f pod.yaml
```

5. Check the pod status:

```bash
kubectl get pods
```

Once the pod is running, it will have access to the persistent volume via the PVC.

### Step 4: Verify the Storage is Mounted
You can verify that the storage is being used correctly by accessing the pod and checking the mounted directory:

```bash
kubectl exec -it nginx-pv-pod -- /bin/bash
ls /usr/share/nginx/html
```

You should see that the persistent volume is correctly mounted in the pod.

### Step 5: Clean Up (Optional)
To delete the PVC and PV when no longer needed, use the following commands:

```bash
kubectl delete pvc local-pvc
kubectl delete pv local-pv
```

Make sure to remove the pod or application using the PVC before deleting it.

### Notes:
- **PersistentVolumeReclaimPolicy**: If you set this to `Retain`, the PV will not be deleted when the PVC is deleted. You’ll need to manually delete the PV or clean up the data for reuse.
- **HostPath** is suitable for testing and development but should **not** be used in production clusters. For production, use network-backed storage solutions like NFS, GlusterFS, or cloud storage options.

This process allows you to manually provision storage and use it in your Kubernetes applications without relying on dynamic provisioning methods like **StorageClass**.

---

# Other Methods to Create PV

There are several methods to create **Persistent Volumes (PVs)** in Kubernetes, depending on the type of storage backend and use case. Here are the most common methods:

### 1. **Manual Creation (Static Provisioning)**
   - In **static provisioning**, an administrator manually creates Persistent Volumes using a `PersistentVolume` YAML manifest.
   - You define the storage backend, capacity, access modes, and more in the YAML file.

   Example of a **manual/static PV** using HostPath:

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-hostpath
   spec:
     capacity:
       storage: 1Gi
     accessModes:
       - ReadWriteOnce
     hostPath:
       path: /mnt/data
   ```

   - This method is commonly used when the storage is local or predefined.

### 2. **Dynamic Provisioning with Storage Classes**
   - In **dynamic provisioning**, Kubernetes automatically provisions Persistent Volumes as needed using **Storage Classes**. A StorageClass defines the type of storage (e.g., AWS EBS, NFS, Ceph, etc.) and allows Kubernetes to automatically create PVs when a PersistentVolumeClaim (PVC) is created.
   - This is often preferred because it automates the provisioning of storage resources.

   Example of a **Storage Class** for dynamic provisioning (AWS EBS example):

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: standard
   provisioner: kubernetes.io/aws-ebs
   parameters:
     type: gp2
   ```

   Then you can create a **PersistentVolumeClaim** that will dynamically provision the storage:

   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-dynamic
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 1Gi
     storageClassName: standard
   ```

### 3. **Cloud Provider Integration (Cloud Volume Types)**
   - Many cloud providers, such as AWS, Google Cloud, and Azure, have integrated volume provisioning for Kubernetes. This method is used when the underlying storage infrastructure is a cloud-based block storage service (e.g., AWS EBS, Google Persistent Disks, Azure Disks).
   - In this case, you use **dynamic provisioning** along with a cloud-native provisioner (e.g., `kubernetes.io/aws-ebs`, `kubernetes.io/gce-pd`, etc.).

   Example for **AWS EBS**:

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: ebs-sc
   provisioner: kubernetes.io/aws-ebs
   parameters:
     type: gp2
   ```

### 4. **Network File System (NFS) Backed Persistent Volumes**
   - An administrator can create PVs backed by NFS (Network File System) storage. You define the NFS server and export path in the PV manifest, and clients (pods) can mount it.
   
   Example of a **PV backed by NFS**:

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-nfs
   spec:
     capacity:
       storage: 10Gi
     accessModes:
       - ReadWriteMany
     nfs:
       server: 192.168.1.100
       path: /exported/path
   ```

   This method is commonly used in environments with network-attached storage solutions.

### 5. **Local Persistent Volumes**
   - Kubernetes supports **local persistent volumes**, where storage is tied to the local disk or directories on a specific node. Unlike HostPath, which can be scheduled on any node, local PVs are tied to a specific node.
   
   Example of a **local PV**:

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: local-pv
   spec:
     capacity:
       storage: 5Gi
     accessModes:
       - ReadWriteOnce
     storageClassName: local-storage
     local:
       path: /mnt/disks/ssd1
     nodeAffinity:
       required:
         nodeSelectorTerms:
           - matchExpressions:
               - key: kubernetes.io/hostname
                 operator: In
                 values:
                   - node1
   ```

### 6. **External Volume Plugins (FlexVolume, CSI)**
   - **CSI (Container Storage Interface)**: Many third-party storage solutions (e.g., Ceph, OpenEBS, Rook) provide **CSI drivers** that enable integration with Kubernetes. With CSI, you can use almost any type of storage system, including cloud, on-premise, and software-defined storage.

   - **FlexVolume**: Kubernetes previously used FlexVolume drivers, but CSI is now the recommended method. However, older environments may still use FlexVolume to provide storage.

   Example of **CSI provisioner** setup:

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: csi-rbd-sc
   provisioner: rbd.csi.ceph.com
   parameters:
     clusterID: "my-cluster-id"
     pool: "my-ceph-pool"
   ```

### 7. **GlusterFS / CephFS / iSCSI**
   - For more advanced distributed storage systems, you can create PVs using systems like **GlusterFS**, **CephFS**, or **iSCSI**. These provide highly available, scalable storage systems that are more suitable for stateful applications in production.
   - These usually involve more complex setup with external storage clusters.

   Example of **GlusterFS PV**:

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: gluster-pv
   spec:
     capacity:
       storage: 10Gi
     accessModes:
       - ReadWriteMany
     glusterfs:
       endpoints: gluster-cluster
       path: myvol
       readOnly: false
   ```

### Summary of Methods to Create PVs:

1. **Static Provisioning**: Manually create PVs.
2. **Dynamic Provisioning**: Automatically create PVs using Storage Classes.
3. **Cloud Provider Integration**: Use cloud volumes like AWS EBS, GCP Persistent Disks, or Azure Disks.
4. **NFS (Network File System)**: Use NFS storage as the backend for your PV.
5. **Local Persistent Volumes**: Use local disk or directories on specific nodes.
6. **CSI (Container Storage Interface)**: Use third-party storage solutions with Kubernetes.
7. **GlusterFS / CephFS / iSCSI**: Advanced distributed storage solutions.

The method you choose depends on the type of storage and infrastructure you're using in your Kubernetes environment.
