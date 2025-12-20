# **Kubernetes Context and Configuration Management**

## **1. Understanding Kubernetes Context**
Kubernetes **contexts** allow you to switch between different clusters, user credentials, and namespaces easily. A context is a grouping of a **cluster**, **namespace**, and **user credentials** stored in the `~/.kube/config` file.

### **1.1. Components of a Kubernetes Context**
Each context in Kubernetes consists of three main elements:
- **Cluster** – The Kubernetes cluster you want to connect to.
- **User** – The credentials used to authenticate.
- **Namespace** – The default namespace used in the cluster.

You can view all contexts using:
```bash
kubectl config get-contexts
```

---

## **2. Viewing Kubernetes Contexts**
To check the current context:
```bash
kubectl config current-context
```

To list all available contexts:
```bash
kubectl config get-contexts
```

The output looks like:
```
CURRENT   NAME                 CLUSTER          AUTHINFO      NAMESPACE
*         my-cluster-context   my-cluster       admin-user    default
          test-context         test-cluster     dev-user      dev
```
- The `*` symbol indicates the active context.
- The `NAMESPACE` column shows the default namespace used.

---

## **3. Switching Kubernetes Context**
To switch to a different context:
```bash
kubectl config use-context test-context
```

Verify the current context:
```bash
kubectl config current-context
```

---

## **4. Creating a New Context**
If you have multiple clusters, you can create a custom context.

Example:
```bash
kubectl config set-context my-custom-context \
    --cluster=my-cluster \
    --user=my-user \
    --namespace=my-namespace
```
This context will now appear when you list contexts.

To use it:
```bash
kubectl config use-context my-custom-context
```

---

## **5. Deleting a Context**
To remove a context:
```bash
kubectl config delete-context my-custom-context
```

---

## **6. Setting Default Namespace for a Context**
By default, `kubectl` commands run in the `default` namespace. You can set a different namespace:

```bash
kubectl config set-context --current --namespace=my-namespace
```

Now, all `kubectl` commands will use `my-namespace` unless specified otherwise.

Verify:
```bash
kubectl config view --minify | grep namespace
```

---

## **7. Viewing Kubernetes Configuration**
The `kubectl` command interacts with Kubernetes using a **configuration file** located at:
```
~/.kube/config
```
To see the active configuration:
```bash
kubectl config view
```

To output a specific section, such as the **current context**:
```bash
kubectl config view --minify
```

---

## **8. Merging Multiple Kubeconfig Files**
If you have multiple Kubernetes clusters, you can merge configuration files.

### **8.1. Export the KUBECONFIG Variable**
```bash
export KUBECONFIG=~/.kube/config:~/kube/config-cluster2
```
Then, verify:
```bash
kubectl config view
```

To make it permanent, add the `export` line to your `~/.bashrc` or `~/.zshrc` file.

---

## **9. Creating and Managing Users in Context**
You can add users to your Kubernetes config:
```bash
kubectl config set-credentials my-user --client-certificate=my-cert.pem --client-key=my-key.pem
```

Then, create a new context with the user:
```bash
kubectl config set-context my-user-context --cluster=my-cluster --user=my-user
```

Switch to the new context:
```bash
kubectl config use-context my-user-context
```

---

## **10. Resetting Kubernetes Configuration**
If you face issues with your Kubernetes configuration, you can reset it by:
```bash
rm -rf ~/.kube/config
```
Or, to reset the current context:
```bash
kubectl config unset current-context
```

---

### **Summary of Useful `kubectl config` Commands**
| Command | Description |
|---------|-------------|
| `kubectl config get-contexts` | List all available contexts |
| `kubectl config current-context` | Show the current context |
| `kubectl config use-context CONTEXT_NAME` | Switch to a specific context |
| `kubectl config set-context NAME --cluster=CLUSTER --user=USER --namespace=NAMESPACE` | Create a new context |
| `kubectl config delete-context NAME` | Delete a context |
| `kubectl config view` | Show the Kubernetes configuration file |
| `kubectl config set-context --current --namespace=NAMESPACE` | Set default namespace for the current context |

---
