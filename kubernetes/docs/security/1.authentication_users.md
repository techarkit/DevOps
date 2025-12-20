## **Understanding Users in Kubernetes**
- **No Built-In User Management**: Kubernetes doesn’t manage users natively (e.g., no `kubectl create user` command). Instead, it relies on external authentication methods (e.g., certificates, tokens, or identity providers) and RBAC for authorization.
- **Your User**: `kubernetes-admin` is a user defined in your `~/.kube/config`, likely using a client certificate for authentication, created during cluster initialization.
- **Key Concepts**:
  - **Authentication**: Verifies a user’s identity (e.g., via certificates, tokens, or OpenID Connect).
  - **Authorization**: Defines what authenticated users can do (via RBAC roles and bindings).

---

### **How Users Are Managed**
1. **Authentication Options**:
   - **Client Certificates**: Common for admin users like `kubernetes-admin` (stored in `~/.kube/config`).
   - **Service Account Tokens**: For applications/pods, not human users.
   - **OpenID Connect (OIDC)**: Integrates with identity providers (e.g., Google, Okta).
   - **Static Token Files**: Simple but less secure.
   - **Webhook or Proxy**: Custom authentication systems.

2. **Authorization**:
   - Managed via RBAC with `Roles`/`ClusterRoles` and `RoleBindings`/`ClusterRoleBindings`.
   - Assigns permissions (e.g., `get`, `create`, `delete`) to users or groups for specific resources (e.g., pods, namespaces).

---

### **Steps to Manage Users in Your Cluster**

#### **1. Check Existing Authentication**
- **Inspect `~/.kube/config`**:
  ```bash
  cat ~/.kube/config
  ```
  Look under `users`:
  ```yaml
  users:
  - name: kubernetes-admin
    user:
      client-certificate-data: <base64-cert>
      client-key-data: <base64-key>
  ```
  - `kubernetes-admin` uses a certificate/key pair, signed by the cluster’s Certificate Authority (CA).
- **Cluster CA**: On the master node, certificates are typically in `/etc/kubernetes/pki`. The CA (e.g., `ca.crt`, `ca.key`) signs user certificates.

#### **2. Add a New User with Certificates**
Let’s create a new user, `dev-user`, with limited access.

- **Generate a Key and CSR**:
  On your workstation:
  ```bash
  openssl genrsa -out dev-user.key 2048
  openssl req -new -key dev-user.key -out dev-user.csr -subj "/CN=dev-user/O=developers"
  ```
  - `CN=dev-user`: Common Name (username).
  - `O=developers`: Organization (optional group, used in RBAC).

- **Sign the CSR with the Cluster CA**:
  - Copy `dev-user.csr` to the master node:
    ```bash
    scp dev-user.csr <master-user>@<master-ip>:/tmp/
    ```
  - On the master, sign it using the cluster CA:
    ```bash
    ssh <master-user>@<master-ip> "sudo openssl x509 -req -in /tmp/dev-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /tmp/dev-user.crt -days 365"
    ```
  - Copy the signed certificate (`dev-user.crt`) back:
    ```bash
    scp <master-user>@<master-ip>:/tmp/dev-user.crt .
    ```

- **Add User to `~/.kube/config`**:
  ```bash
  kubectl config set-credentials dev-user --client-certificate=dev-user.crt --client-key=dev-user.key
  kubectl config set-context dev-user@kubernetes --cluster=kubernetes --namespace=default --user=dev-user
  ```
  - Check:
    ```bash
    kubectl config get-contexts
    ```
    Output:
    ```
    CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
    *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   mlflow
              dev-user@kubernetes           kubernetes   dev-user           default
    ```

- **Switch to Test**:
  ```bash
  kubectl config use-context dev-user@kubernetes
  kubectl get pods  # Likely fails due to no permissions yet
  ```

#### **3. Assign Permissions with RBAC**
- **Create a Role** (e.g., read-only in `default` namespace):
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: default
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
    namespace: default
    name: pod-reader-binding
  subjects:
  - kind: User
    name: dev-user  # Matches CN from certificate
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

- **Test Access**:
  ```bash
  kubectl config use-context dev-user@kubernetes
  kubectl get pods  # Should work in `default` namespace
  kubectl create pod test-pod --image=nginx --dry-run=client  # Should fail (no `create` permission)
  ```

#### **4. Manage Existing Users**
- **List Users**: Kubernetes doesn’t list users directly—they’re in `~/.kube/config` or server-side auth configs. Check:
  - `~/.kube/config` for client-side users.
  - Cluster audit logs or RBAC bindings for active users:
    ```bash
    kubectl get rolebindings,clusterrolebindings -A -o wide
    ```
- **Modify Permissions**: Update `Role`/`ClusterRole` or bindings:
  - Example: Give `dev-user` cluster-wide pod read access:
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: cluster-pod-reader
    subjects:
    - kind: User
      name: dev-user
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: view  # Built-in read-only role
      apiGroup: rbac.authorization.k8s.io
    ```
    ```bash
    kubectl apply -f cluster-pod-reader.yaml
    ```

- **Remove User**:
  - Delete from `~/.kube/config`:
    ```bash
    kubectl config unset users.dev-user
    kubectl config unset contexts.dev-user@kubernetes
    ```
  - Revoke certificate (if compromised):
    - Regenerate CA and reissue all certificates (complex, not covered here).

#### **5. Alternative: Use OIDC (Optional)**
- For many users, integrate with an identity provider (e.g., Google):
  - Edit kube-apiserver flags on the master (e.g., `/etc/kubernetes/manifests/kube-apiserver.yaml`):
    ```yaml
    - --oidc-issuer-url=https://accounts.google.com
    - --oidc-client-id=<your-client-id>
    ```
  - Requires cluster restart and OIDC setup (more advanced).

---

### **Your Current User: `kubernetes-admin`**
- **Privileges**: Likely bound to the `cluster-admin` ClusterRole (check):
  ```bash
  kubectl get clusterrolebindings -o wide | grep kubernetes-admin
  ```
  - Example: `cluster-admin` binding gives full control.
- **Management**: You can limit its scope by creating a new binding with fewer permissions, but typically keep it as is for admin tasks.

---

### **Conclusion**
- **Current State**: `kubernetes-admin` is your admin user, using certificates.
- **Add Users**: Generate certificates, add to `~/.kube/config`, and assign RBAC roles.
- **Manage**: Adjust permissions with RBAC, remove users by deleting credentials/contexts.
- For your cluster, start with certificate-based users (like `dev-user`) for simplicity, then explore OIDC for larger teams.

Let me know if you want to create another user or tweak `kubernetes-admin`!
