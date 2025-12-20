Let’s dive into **authorization** in Kubernetes using **Role-Based Access Control (RBAC)**, building on your current setup where `kubernetes-admin` is your active user (from `kubectl config get-contexts`). RBAC is how you control what users (like `kubernetes-admin` or a new user like `dev-user`) or entities (like service accounts) can do in your cluster with one master and two worker nodes. I’ll explain how RBAC works, its key components, and provide practical examples tailored to your environment.

---

### **What is RBAC in Kubernetes?**
- **RBAC** (Role-Based Access Control) is Kubernetes’ primary authorization mechanism.
- It defines **permissions** (e.g., `get`, `create`, `delete`) for **resources** (e.g., pods, deployments) and assigns them to **subjects** (users, groups, or service accounts).
- RBAC ensures fine-grained control—e.g., `kubernetes-admin` might have full access, while `dev-user` only gets to list pods in the `mlflow` namespace.

---

### **Key RBAC Components**
1. **`Role` and `ClusterRole`**:
   - **Role**: Defines permissions within a specific namespace (e.g., `mlflow`).
   - **ClusterRole**: Defines permissions cluster-wide (across all namespaces or for cluster-level resources like nodes).
   - Both specify **rules**: what actions (`verbs`) can be performed on which resources.

2. **`RoleBinding` and `ClusterRoleBinding`**:
   - **RoleBinding**: Links a `Role` to a subject (e.g., user `dev-user`) in a specific namespace.
   - **ClusterRoleBinding**: Links a `ClusterRole` to a subject cluster-wide.
   - Subjects can be users (e.g., `kubernetes-admin`), groups (e.g., `developers`), or service accounts.

3. **`Rules`**:
   - Define:
     - **apiGroups**: Resource group (e.g., `""` for core, `apps` for deployments).
     - **resources**: What to act on (e.g., `pods`, `deployments`).
     - **verbs**: Actions allowed (e.g., `get`, `list`, `create`, `delete`).

---

### **How RBAC Works**
- When a user (e.g., `kubernetes-admin`) runs a command like `kubectl get pods -n mlflow`:
  1. **Authentication**: The API server verifies the user’s identity (e.g., via `kubernetes-admin`’s certificate in `~/.kube/config`).
  2. **Authorization**: RBAC checks if the user has a `Role`/`ClusterRole` (via a binding) allowing `get` on `pods` in the `mlflow` namespace.
  3. **Execution**: If permitted, the command succeeds; otherwise, it fails with a `Forbidden` error.

---

### **Your Current Authorization: `kubernetes-admin`**
- **Likely Privileges**: `kubernetes-admin` is probably bound to the built-in `cluster-admin` `ClusterRole`, giving it full control:
  ```bash
  kubectl get clusterrolebindings -o wide | grep kubernetes-admin
  ```
  Example output:
  ```
  NAME             ROLE                    AGE   SUBJECTS
  cluster-admin    ClusterRole/cluster-admin  10d   kubernetes-admin
  ```
- ** cluster-admin Role**: Grants `*` (all verbs) on `*` (all resources) cluster-wide:
  ```bash
  kubectl describe clusterrole cluster-admin
  ```
  - Output includes: `verbs: [*]`, `resources: [*]`.

---

### **Practical RBAC Examples**
Let’s manage authorization for your cluster, starting with `kubernetes-admin` and adding a new user, `dev-user`.

#### **1. Check Existing Permissions**
- **Test `kubernetes-admin`**:
  ```bash
  kubectl get pods -n mlflow
  kubectl create namespace test-ns
  ```
  - These succeed because `kubernetes-admin` likely has unrestricted access.

#### **2. Create a Limited User (`dev-user`)**
- From earlier, assume `dev-user` is added to `~/.kube/config` with a certificate:
  ```bash
  kubectl config use-context dev-user@kubernetes
  kubectl get pods -n default  # Fails: "Forbidden"
  ```

#### **3. Define a Namespace-Specific Role**
- **Goal**: Allow `dev-user` to read pods in the `mlflow` namespace.
- Create a `Role`:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: mlflow
    name: pod-reader
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  ```
  Apply:
  ```bash
  kubectl apply -f pod-reader-role.yaml
  ```

- **Bind the Role to `dev-user`**:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    namespace: mlflow
    name: pod-reader-binding
  subjects:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io
  roleRef:
    kind: Role
    name: pod-reader
    apiGroup: rbac.authorization.k8s.io
  ```
  Apply:
  ```bash
  kubectl apply -f pod-reader-binding.yaml
  ```

- **Test**:
  ```bash
  kubectl config use-context dev-user@kubernetes
  kubectl get pods -n mlflow  # Succeeds
  kubectl get pods -n default  # Fails (no permission outside mlflow)
  kubectl create pod test-pod -n mlflow --image=nginx --dry-run=client  # Fails (no create permission)
  ```

#### **4. Grant Cluster-Wide Read Access**
- **Goal**: Let `dev-user` read pods across all namespaces.
- Use the built-in `view` `ClusterRole`:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: dev-user-viewer
  subjects:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io
  roleRef:
    kind: ClusterRole
    name: view  # Built-in read-only role
    apiGroup: rbac.authorization.k8s.io
  ```
  Apply:
  ```bash
  kubectl apply -f dev-user-viewer.yaml
  ```

- **Test**:
  ```bash
  kubectl config use-context dev-user@kubernetes
  kubectl get pods -n mlflow  # Succeeds
  kubectl get pods -n default  # Succeeds
  kubectl get nodes  # Succeeds (view includes cluster-level read)
  kubectl delete pod <pod-name> -n mlflow  # Fails (view is read-only)
  ```

#### **5. Restrict `kubernetes-admin` (Optional)**
- **Goal**: Limit `kubernetes-admin` to specific actions (not recommended for your only admin, but for demonstration).
- Create a custom `ClusterRole`:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: limited-admin
  rules:
  - apiGroups: [""]
    resources: ["pods", "namespaces"]
    verbs: ["get", "list", "create"]
  ```
  Apply:
  ```bash
  kubectl apply -f limited-admin.yaml
  ```

- Replace the `cluster-admin` binding:
  ```bash
  kubectl delete clusterrolebinding cluster-admin
  ```
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: limited-admin-binding
  subjects:
  - kind: User
    name: kubernetes-admin
    apiGroup: rbac.authorization.k8s.io
  roleRef:
    kind: ClusterRole
    name: limited-admin
    apiGroup: rbac.authorization.k8s.io
  ```
  Apply:
  ```bash
  kubectl apply -f limited-admin-binding.yaml
  ```

- **Test**:
  ```bash
  kubectl config use-context kubernetes-admin@kubernetes
  kubectl get pods -n mlflow  # Succeeds
  kubectl create namespace test-ns  # Succeeds
  kubectl delete namespace test-ns  # Fails (no delete permission)
  ```

---

### **Best Practices for Your Cluster**
- **Least Privilege**: Assign minimal permissions (e.g., `view` for developers, custom roles for specific tasks).
- **Namespace Isolation**: Use `Role` and `RoleBinding` for namespace-specific access (e.g., `mlflow`, `monitoring`).
- **Admin Safety**: Keep `kubernetes-admin` with `cluster-admin` unless splitting admin duties across users.
- **Group Usage**: Use `O=<group-name>` in certificates (e.g., `O=developers`) and bind roles to groups for easier management:
  ```yaml
  subjects:
  - kind: Group
    name: developers
    apiGroup: rbac.authorization.k8s.io
  ```

---

### **Troubleshooting RBAC**
- **Permission Denied**:
  ```bash
  Error from server (Forbidden): pods is forbidden: User "dev-user" cannot list resource "pods"...
  ```
  - Check bindings:
    ```bash
    kubectl get rolebindings -n mlflow -o yaml
    kubectl get clusterrolebindings -o yaml
    ```
- **Dry Run**: Test permissions without applying:
  ```bash
  kubectl auth can-i get pods -n mlflow --as=dev-user
  ```

---

### **Your Context**
- **Current**: `kubernetes-admin` has full access, ideal for your admin tasks (e.g., managing NFS, PVCs like `prometheus-pvc`).
- **Next Steps**: Add users like `dev-user` for specific tasks (e.g., monitoring MLflow pods) using RBAC, keeping `kubernetes-admin` as the fallback.

