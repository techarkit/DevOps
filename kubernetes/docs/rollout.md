### **What is a Rollout in Kubernetes?**
A **rollout** in Kubernetes refers to the process of **deploying a new version of an application** while ensuring minimal downtime and smooth transitions. Kubernetes manages rollouts automatically when you update a **Deployment**, **DaemonSet**, or **StatefulSet**.

---

### **Key Concepts of Rollouts**
1. **Rolling Update (Default Strategy)**
   - Updates pods **gradually** to avoid downtime.
   - Old pods are **terminated** while new ones **start** progressively.
   - Ensures that a certain number of pods remain available during the rollout.

2. **Recreate Strategy**
   - **Deletes all existing pods first** and then creates new ones.
   - Causes downtime but ensures a clean deployment.

3. **Rolling Back**
   - If a deployment fails, Kubernetes allows you to **rollback** to the last stable version.

---

### **Useful Commands for Rollouts**
#### **1. Check Rollout Status**
```bash
kubectl rollout status deployment <deployment-name>
```

#### **2. View Rollout History**
```bash
kubectl rollout history deployment <deployment-name>
```

#### **3. Roll Back to the Previous Version**
```bash
kubectl rollout undo deployment <deployment-name>
```

#### **4. Pause a Rollout (Stop Deploying Changes)**
```bash
kubectl rollout pause deployment <deployment-name>
```

#### **5. Resume a Paused Rollout**
```bash
kubectl rollout resume deployment <deployment-name>
```

---

### **Example: Rolling Update in a Deployment**
#### **Step 1: Create a Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: nginx:1.19
```
```bash
kubectl apply -f deployment.yaml
```

#### **Step 2: Update the Deployment**
Modify the container image in the YAML file:
```yaml
- name: my-app-container
  image: nginx:1.21
```
Apply the update:
```bash
kubectl apply -f deployment.yaml
```
Check the rollout progress:
```bash
kubectl rollout status deployment my-app
```

#### **Step 3: Roll Back if Needed**
```bash
kubectl rollout undo deployment my-app
```

---

### **Conclusion**
- A **rollout** manages **progressive updates** in Kubernetes.
- By default, Kubernetes performs a **rolling update** to avoid downtime.
- You can **pause, resume, check status, and roll back** deployments.

Would you like a detailed guide on Canary or Blue-Green deployments? 🚀