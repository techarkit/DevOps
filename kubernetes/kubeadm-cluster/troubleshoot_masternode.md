## API server is down

If the API server is down with following error:

```bash
The connection to the server 192.168.1.181:6443 was refused - did you specify the right host or port?
```

**kubectl won’t work** because it can't communicate with the cluster. Instead, you’ll need to check pod status manually using **crictl** or directly inspect logs.

---

### ✅ **How to Check etcd and Control Plane Without kubectl**
Since Kubernetes is down, you need to check pods from the **container runtime** (`containerd` or `docker`).

#### **Check Static Pods Manually**
```sh
sudo crictl ps -a
```
- If pods for kubernetes components are not running, check the logs.
- API server cannot run properly if etcd is not running because etcd is the primary key-value store for Kubernetes. The API server relies on etcd to store and retrieve cluster state information.


---
## Check Logs

#### 2 **Check etcd Logs**
```sh
sudo crictl logs $(sudo crictl ps -q --name etcd)
```
or find the container ID and use:
```sh
sudo crictl logs <container-id>
```

#### 1 **Check API Server Logs**
```sh
sudo crictl logs $(sudo crictl ps -q --name kube-apiserver)
```
or find the container ID and use:
```sh
sudo crictl logs <container-id>
```



---
## Check Manifest

#### 3️⃣ **Check Static Pod Manifest**
Since **etcd is a static pod**, it's defined in:
```sh
cat /etc/kubernetes/manifests/etcd.yaml
```
Check for:
- **Correct IP addresses** in `--listen-client-urls`
- **Volume mounts** for etcd data

#### 4️⃣ **Manually Restart etcd**
Since kubelet manages the static pod, you can force a restart by **modifying the manifest**:
```sh
sudo touch /etc/kubernetes/manifests/etcd.yaml
```
Or restart kubelet:
```sh
sudo systemctl restart kubelet
```
After a minute, check if **etcd is back** using:
```sh
sudo crictl ps | grep etcd
```

---

### 🔥 **If etcd is Running, Restart API Server**
Once etcd is fixed, restart the **API server**:
```sh
sudo systemctl restart kubelet
```
Then try:
```sh
kubectl get pods -n kube-system
```
If it still fails, check API server logs:
```sh
sudo crictl logs $(sudo crictl ps -q --name kube-apiserver)
```

---

### 🚀 **Next Steps**
- If etcd logs show errors, post them here!
- If `crictl` isn't installed, install it with:
  ```sh
  sudo apt install cri-tools -y  # (Ubuntu)
  sudo yum install cri-tools -y  # (CentOS/RHEL)
  ```
  
---

## **kube-apiserver** is restarting frequently

If **kube-apiserver** is restarting frequently, we need to diagnose why it's failing. The most likely causes are:  

- **etcd connection issues**  
- **Certificate or authentication problems**  
- **Port binding conflicts**  
- **Resource constraints (CPU/memory)**  

---

## ✅ **Step-by-Step Debugging**
### **1️⃣ Check API Server Logs**
Since the API server is restarting, you need to check its logs before it crashes. Run:  
```sh
sudo crictl logs $(sudo crictl ps -q --name kube-apiserver)
```
- Look for errors related to:
  - **etcd connection issues** (`etcdserver: request timed out`)
  - **certificate failures** (`x509: certificate signed by unknown authority`)
  - **failed to bind to port 6443**

---

### **2️⃣ Check etcd Health**
If etcd is failing, the API server will crash. Check etcd logs:  
```sh
sudo crictl logs $(sudo crictl ps -q --name etcd)
```
Then, verify etcd health:  
```sh
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --cacert=/etc/kubernetes/pki/etcd/ca.crt endpoint health
```
- If etcd is unhealthy, the API server will keep crashing.

---

### **3️⃣ Check kube-apiserver Manifest**
Since this is a static pod, check its YAML configuration:  
```sh
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```
Look for:
- **Wrong etcd address** (`--etcd-servers=https://127.0.0.1:2379`)
- **Missing or expired certificates**
- **Incorrect port binding (`--secure-port=6443`)**

---

### **4️⃣ Check Kubelet Logs (Manages Static Pods)**
If kubelet is failing to restart the API server properly, check its logs:  
```sh
sudo journalctl -u kubelet -f
```
- Look for **"failed to create pod sandbox"** or other errors.

---

### **5️⃣ Ensure Ports Are Free**
Ensure no other service is blocking port **6443**:
```sh
sudo netstat -tulnp | grep 6443
```
If another service is using it, **stop that service** and restart the API server.

---

## 🔥 **Final Fix: Restart Components**
After troubleshooting, restart everything:
```sh
sudo systemctl restart kubelet
```
Then check:
```sh
kubectl get pods -n kube-system
```

Let me know what you find! 🚀
