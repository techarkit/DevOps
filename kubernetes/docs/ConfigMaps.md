# **ConfigMaps in Kubernetes**

A **ConfigMap** in Kubernetes is a resource used to store configuration data in key-value pairs, decoupling configuration from application code. It allows you to manage settings, environment variables, or configuration files separately from container images, making applications more portable and easier to update.

---

## **1. What is a ConfigMap?**
- **Definition**: A Kubernetes API object that holds non-sensitive configuration data as key-value pairs or files.
- **Purpose**: 
  - Provides a way to inject configuration into Pods without hardcoding it into the image.
  - Enables dynamic updates to application settings without rebuilding containers.
- **Comparison**: Unlike **Secrets** (for sensitive data like passwords), ConfigMaps are for non-confidential data (e.g., app settings, URLs).

---

## **2. Key Features**
- **Key-Value Storage**: Stores data as simple key-value pairs (e.g., `database_url: mysql://localhost:3306`).
- **File Storage**: Can store entire configuration files (e.g., `nginx.conf`).
- **Injection Methods**: Can be mounted as environment variables, command-line arguments, or files in a Pod.
- **Decoupling**: Separates configuration from the application, supporting the 12-factor app methodology.
- **Namespace-Scoped**: Exists within a specific Kubernetes namespace.

---

## **3. Structure of a ConfigMap**
A ConfigMap is defined in YAML or JSON and has two main data fields:
- **`data`**: Key-value pairs for simple settings.
- **`binaryData`**: Base64-encoded data for binary files (less common).

### Example ConfigMap YAML:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database_url: "mysql://localhost:3306"
  log_level: "debug"
```

---

## **4. Creating a ConfigMap**

### **a) Via YAML File**
1. Save the above YAML as `app-config.yaml`.
2. Apply it:
   ```bash
   kubectl apply -f app-config.yaml
   ```

### **b) Via Command Line (Imperative)**
- From literal values:
  ```bash
  kubectl create configmap app-config --from-literal=database_url=mysql://localhost:3306 --from-literal=log_level=debug
  ```
- From a file:
  ```bash
  echo "server.port=8080" > config.properties
  kubectl create configmap app-config --from-file=config.properties
  ```

### **c) Verify Creation**
```bash
kubectl get configmap app-config -o yaml
```

---

## **5. Using ConfigMaps in Pods**

ConfigMaps can be consumed by Pods in several ways:

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
    - name: DB_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
```
- **Explanation**: `DB_URL` and `LOG_LEVEL` are set from the ConfigMap’s `database_url` and `log_level` keys.

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
    - name: config-volume
      mountPath: "/etc/config"
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```
- **Result**: Creates files under `/etc/config` (e.g., `/etc/config/database_url`, `/etc/config/log_level`) with the values as content.

### **c) As Command-Line Arguments**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-app
    image: my-app:latest
    command: ["/bin/sh", "-c"]
    args: ["echo $DB_URL && my-app"]
    env:
    - name: DB_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
```
- **Explanation**: Passes `database_url` to the app via an environment variable used in the command.

---

## **6. Updating ConfigMaps**
- **Edit**: Modify with `kubectl edit configmap app-config`.
- **Apply**: Update via YAML: `kubectl apply -f updated-config.yaml`.
- **Behavior**: Pods don’t automatically reload ConfigMap changes:
  - **Environment Variables**: Require Pod restart.
  - **Mounted Volumes**: Updates propagate after a short delay (usually seconds), depending on kubelet sync interval.

---

## **7. Practical Examples**

### **a) Simple Web App Config**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  api_endpoint: "https://api.example.com"
  max_connections: "100"
---
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  containers:
  - name: web-app
    image: nginx
    env:
    - name: API_ENDPOINT
      valueFrom:
        configMapKeyRef:
          name: web-config
          key: api_endpoint
```

### **b) Config File for Nginx**
```bash
# Create a file
echo "server { listen 80; }" > nginx.conf
kubectl create configmap nginx-config --from-file=nginx.conf
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config
      mountPath: "/etc/nginx/conf.d"
  volumes:
  - name: config
    configMap:
      name: nginx-config
```

---

## **8. Best Practices**
- **Naming**: Use descriptive names (e.g., `appname-config`) and namespaces.
- **Granularity**: Split large configs into multiple ConfigMaps (e.g., `db-config`, `app-config`).
- **Secrets vs. ConfigMaps**: Use ConfigMaps for non-sensitive data; Secrets for passwords, keys.
- **Versioning**: Include version info in metadata (e.g., `labels: {version: v1}`) for tracking.
- **Minimize Reloads**: Design apps to watch mounted files for changes if frequent updates are needed.

---

## **9. Troubleshooting**
- **Not Found**: Ensure the ConfigMap exists in the same namespace:
  ```bash
  kubectl get configmap -n <namespace>
  ```
- **No Update**: Restart Pods if using environment variables:
  ```bash
  kubectl delete pod my-pod --force
  ```
- **Debug**: Check Pod logs or describe:
  ```bash
  kubectl describe pod my-pod
  ```

---

## **10. Limitations**
- **Size**: Limited to 1MB (etcd storage limit).
- **No Encryption**: Plain text; use Secrets for sensitive data.
- **Static Nature**: Changes don’t automatically restart Pods unless using volumes with live updates.

---

## **11. Comparison with Secrets**
| **Feature**       | **ConfigMap**          | **Secret**             |
|-------------------|------------------------|------------------------|
| **Data Type**     | Non-sensitive         | Sensitive (e.g., keys) |
| **Encoding**      | Plain text            | Base64-encoded         |
| **Default Access** | Readable              | Encrypted in etcd      |
| **Use Case**      | App settings, files   | Passwords, tokens      |

---

## **12. Summary**
- **ConfigMap** is a Kubernetes resource for storing and injecting configuration data into Pods.
- Supports key-value pairs or files, used via env vars, volumes, or args.
- Enhances flexibility by separating config from code.
- Managed with `kubectl`, scoped to namespaces.

---

## **Try It Yourself**
1. Create a ConfigMap:
   ```bash
   kubectl create configmap test-config --from-literal=key1=value1
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
           configMapKeyRef:
             name: test-config
             key: key1
   ```
   Apply: `kubectl apply -f test-pod.yaml`
3. Check output:
   ```bash
   kubectl logs test-pod
   # Output: value1
   ```

Let me know if you need help with a specific ConfigMap scenario! 🚀
