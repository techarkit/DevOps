### **What is Kustomize?**  
Kustomize is a tool integrated into `kubectl` that allows **customizing Kubernetes YAML configurations** without modifying the original manifests. It helps manage configurations across different environments (e.g., dev, staging, production) using **overlays** instead of templating languages like Helm.

---

### **Key Features of Kustomize**  
- **Patch YAML without modifying the original**  
- **Manage multiple environments (overlays)**  
- **Declarative configuration with `kustomization.yaml`**  
- **Native support in `kubectl` (`kubectl apply -k`)**

---

### **Basic Usage Example**  
#### **1. Create a Base Configuration**  
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: nginx:latest
```

#### **2. Create `kustomization.yaml`**
```yaml
# kustomization.yaml
resources:
  - deployment.yaml

patches:
  - target:
      kind: Deployment
      name: my-app
    patch: | 
      - op: replace
        path: /spec/replicas
        value: 5
```
This **changes the replica count from 3 to 5 without modifying `deployment.yaml`**.

#### **3. Apply Kustomization**
```bash
kubectl apply -k .
```

---

### **Checking Installed Version**
```bash
kubectl kustomize version
```

---

### **Use Cases of Kustomize**
- Modifying configurations **per environment**  
- Applying **labels, annotations, and patches**  
- Reusing and **extending Kubernetes manifests**  
- Managing **configuration changes efficiently**  

Would you like help setting up a `kustomization.yaml` for your use case? 🚀
