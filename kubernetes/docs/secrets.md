# **Secrets in Kubernetes**

A **Secret** in Kubernetes is a resource designed to store and manage sensitive data, such as passwords, API keys, certificates, or tokens. Secrets keep confidential information separate from application code and container images, enhancing security and flexibility in a Kubernetes cluster.

---

## **1. What is a Secret?**
- **Definition**: A Kubernetes API object that securely holds sensitive data in key-value pairs or as binary content.
- **Purpose**: 
  - Protects confidential information from being exposed in plain text within Pod definitions or ConfigMaps.
  - Provides a mechanism to inject sensitive data into Pods without hardcoding it.
- **Comparison**: Unlike **ConfigMaps** (for non-sensitive configuration), Secrets are specifically for sensitive data and include basic security features like encryption at rest.

---

## **2. Key Features**
- **Sensitive Data Storage**: Stores items like passwords, OAuth tokens, or SSH keys.
- **Base64 Encoding**: Data is stored as base64-encoded strings (not encrypted by default, but obscured).
- **Injection Methods**: Can be mounted as environment variables, files in a Pod, or used by other Kubernetes components (e.g., image pull secrets).
- **Encryption**: Stored encrypted in etcd (Kubernetes’ backing store) if encryption is enabled at the cluster level.
- **Namespace-Scoped**: Secrets are specific to a Kubernetes namespace.

---

## **3. Structure of a Secret**
A Secret is defined in YAML or JSON with two main data fields:
- **`data`**: Base64-encoded key-value pairs for sensitive data.
- **`stringData`**: Optional plain-text data (automatically base64-encoded by Kubernetes on creation).

### Example Secret YAML:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: default
type: Opaque  # Default type for generic secrets
data:
  db_password: cGFzc3dvcmQ=  # Base64 for "password"
stringData:  # Optional, plain text
  api_key: mysecretkey
```

- **Note**: `cGFzc3dvcmQ=` is the base64 encoding of "password". Use `echo -n "password" | base64` to generate it.

---

## **4. Types of Secrets**
- **`Opaque`**: Generic secrets (default type) for arbitrary key-value pairs.
- **`kubernetes.io/dockerconfigjson`**: For Docker registry credentials (image pull secrets).
- **`kubernetes.io/tls`**: For TLS certificates and keys.
- **`kubernetes.io/service-account-token`**: Auto-generated for service accounts.

---

## **5. Creating a Secret**

### **a) Via YAML File**
1. Save the above YAML as `app-secret.yaml`.
2. Apply it:
   ```bash
   kubectl apply -f app-secret.yaml
   ```

### **b) Via Command Line (Imperative)**
- From literal values:
  ```bash
  kubectl create secret generic app-secret --from-literal=db_password=password --from-literal=api_key=mysecretkey
  ```
- From files:
  ```bash
  echo -n "password" > dbpass.txt
  kubectl create secret generic app-secret --from-file=db_password=dbpass.txt
  ```

### **c) Verify Creation**
```bash
kubectl get secret app-secret -o yaml
```
- **Decode Data**: View plain text (careful with sensitive data):
  ```bash
  kubectl get secret app-secret -o jsonpath='{.data.db_password}' | base64 -d
  # Output: password
  ```

---

## **6. Using Secrets in Pods**

Secrets can be consumed by Pods in several ways:

### **a) As Environment Variables**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-app
    image: my-app:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: db_password
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: api_key
```
- **Explanation**: `DB_PASSWORD` and `API_KEY` are set from the Secret’s keys.

### **b) As a Volume (Files)**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-app
    image: my-app:latest
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
```
- **Result**: Creates files under `/etc/secrets` (e.g., `/etc/secrets/db_password`, `/etc/secrets/api_key`) with decoded content.

### **c) For Image Pull Secrets**
```bash
kubectl create secret docker-registry my-registry-secret --docker-username=user --docker-password=pass --docker-server=myregistry.com
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-app
    image: myregistry.com/my-app:latest
  imagePullSecrets:
  - name: my-registry-secret
```
- **Explanation**: Authenticates to pull images from a private registry.

---

## **7. Updating Secrets**
- **Edit**: Modify with `kubectl edit secret app-secret` (edit base64 values manually).
- **Apply**: Update via YAML: `kubectl apply -f updated-secret.yaml`.
- **Behavior**: Pods don’t automatically reload Secret changes:
  - **Environment Variables**: Require Pod restart.
  - **Mounted Volumes**: Updates propagate after a delay (kubelet sync interval).

---

## **8. Practical Examples**

### **a) Database Credentials**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
data:
  username: dXNlcg==  # "user"
  password: cGFzcw==  # "pass"
---
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
spec:
  containers:
  - name: mysql-client
    image: mysql
    env:
    - name: MYSQL_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: MYSQL_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### **b) TLS Certificate**
```bash
kubectl create secret tls web-secret --cert=server.crt --key=server.key
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: tls-volume
      mountPath: "/etc/nginx/certs"
  volumes:
  - name: tls-volume
    secret:
      secretName: web-secret
```

---

## **9. Security Considerations**
- **Base64 ≠ Encryption**: Data is only obscured, not encrypted by default in etcd.
- **Enable Encryption**: Configure etcd encryption:
  ```yaml
  apiVersion: apiserver.config.k8s.io/v1
  kind: EncryptionConfiguration
  resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <32-byte-base64-key>
  ```
  Apply with `--encryption-provider-config` on the API server.
- **Access Control**: Use RBAC to restrict Secret access:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: secret-reader
  rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]
  ```

---

## **10. Best Practices**
- **Naming**: Use clear names (e.g., `appname-secret`) and namespaces.
- **Separation**: Store unrelated secrets separately (e.g., `db-secret`, `api-secret`).
- **Minimize Exposure**: Avoid logging Secret values; use volumes over env vars for files.
- **Immutable**: Set `immutable: true` for Secrets that won’t change (improves performance):
  ```yaml
  kind: Secret
  metadata:
    name: static-secret
  immutable: true
  data:
    key: dmFsdWU=
  ```

---

## **11. Troubleshooting**
- **Not Found**: Verify namespace and name:
  ```bash
  kubectl get secret -n <namespace>
  ```
- **Permission Denied**: Check RBAC or Pod spec syntax.
- **Decode Issues**: Ensure base64 values are correct:
  ```bash
  echo "cGFzc3dvcmQ=" | base64 -d  # Should output "password"
  ```

---

## **12. Limitations**
- **Size**: Limited to 1MB (etcd limit).
- **No Auto-Rotation**: Requires external tools (e.g., Vault) for key rotation.
- **Propagation Delay**: Volume updates aren’t instant.

---

## **13. Comparison with ConfigMaps**
| **Feature**       | **Secret**             | **ConfigMap**          |
|-------------------|------------------------|------------------------|
| **Data Type**     | Sensitive             | Non-sensitive          |
| **Encoding**      | Base64                | Plain text             |
| **Security**      | Encrypted in etcd (if enabled) | Plain in etcd  |
| **Use Case**      | Passwords, keys       | App settings, files    |

---

## **14. Summary**
- **Secrets** securely store sensitive data in Kubernetes, injected into Pods as env vars or files.
- Base64-encoded by default, with optional etcd encryption.
- Managed with `kubectl`, scoped to namespaces, and critical for secure app deployment.

---

## **Try It Yourself**
1. Create a Secret:
   ```bash
   kubectl create secret generic test-secret --from-literal=key1=secretvalue
   ```
2. Use it in a Pod:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-pod
   spec:
     containers:
     - name: test
       image: busybox
       command: ["sh", "-c", "echo $KEY1 && sleep 3600"]
       env:
       - name: KEY1
         valueFrom:
           secretKeyRef:
             name: test-secret
             key: key1
   ```
   Apply: `kubectl apply -f test-pod.yaml`
3. Check:
   ```bash
   kubectl logs test-pod
   # Output: secretvalue
   ```

---
