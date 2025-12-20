# **Service Account in Kubernetes**
A **Service Account** in Kubernetes is an identity used by **pods** to interact with the Kubernetes API. It allows applications running inside the cluster to access Kubernetes resources securely.

---

## **1. What is a Service Account?**
- **By default**, every pod in Kubernetes runs under the **default service account**.
- A **custom service account** can be created for fine-grained control.
- It is different from **user accounts**, which are for human users.
- Service accounts **authenticate pods** but do not provide authorization (RBAC handles authorization).

---

## **2. Why Use a Service Account?**
- Secure API access for pods.
- Fine-grained permission control using **Role-Based Access Control (RBAC)**.
- Prevent applications from having excessive permissions.
- Use different service accounts for different workloads.

---

## **3. Default Service Account**
Every namespace in Kubernetes has a **default** service account named **`default`**.

To check the default service account:
```bash
kubectl get serviceaccounts -n default
```
**Output:**
```
NAME      SECRETS   AGE
default   1         10d
```

To check details of a service account:
```bash
kubectl describe serviceaccount default
```

---

## **4. Creating a Custom Service Account**
### **Step 1: Create a Service Account**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

Apply it using:
```bash
kubectl apply -f service-account.yaml
```

Check if it's created:
```bash
kubectl get serviceaccounts
```

---

### **Step 2: Assign the Service Account to a Pod**
You can assign a service account to a pod by specifying it in the pod spec.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: my-container
    image: nginx
```

---

## **5. Using Service Account with RBAC**
By default, a service account **has no permissions**. You must grant permissions using **Roles** and **RoleBindings**.

### **Example: Grant Pod Read Access**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Create a **RoleBinding** to bind the service account:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the YAML files:
```bash
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
```

Now, the **`my-service-account`** can read pod details inside the `default` namespace.

---

## **6. Checking the Service Account Token**
Each service account gets a **secret token** stored as a Kubernetes secret.

Check the token:
```bash
kubectl get secrets
```

Decode the token:
```bash
kubectl get secret <secret-name> -o jsonpath='{.data.token}' | base64 --decode
```

You can use this token to authenticate API requests.

---

## **7. Deleting a Service Account**
```bash
kubectl delete serviceaccount my-service-account
```

---

## **8. Key Takeaways**
- **Service Accounts are for pods**, not users.
- Every namespace has a **default** service account.
- Use **RBAC** to grant permissions to a service account.
- Service accounts have **tokens** stored in Kubernetes secrets.
- Assign custom service accounts to **limit pod permissions**.

Would you like a **hands-on example** using a Kubernetes API request with a service account token? 🚀