### **Setting Up Ingress in Kubernetes**

#### **Overview**
- **Purpose**: Ingress manages external HTTP/HTTPS access to pods by defining routing rules (e.g., paths or domains), offering a single entry point for multiple services with features like load balancing and TLS termination.
- **Benefits**: Provides advanced routing (e.g., `/app1`, `app1.example.com`) over a single IP, improving on `NodePort` or `LoadBalancer` Services, with support for SSL and path rewriting.
- **Components**:
  - **Ingress Resource**: Specifies routing rules.
  - **Ingress Controller**: Implements rules (e.g., NGINX, Traefik) as a pod.
  - **Backend Service**: Targets pods (typically `ClusterIP`).

#### **Prerequisites**
- A running Kubernetes cluster with pods to expose.
- `kubectl` configured on your workstation.
- Network access from your client to cluster nodes (e.g., via node IPs).

---

#### **Steps to Set Up Ingress**

##### **Step 1: Verify Your Pod and Labels**
- Ensure the pod(s) to expose have consistent labels (e.g., `app: my-app`).
- Check pod details:
  ```bash
  kubectl get pods -n <namespace> -o wide
  ```
  - Example:
    ```
    NAME            READY   STATUS    AGE    IP           NODE
    my-app-abc123   1/1     Running   1d     10.244.1.5   node1
    ```
- Confirm labels:
  ```bash
  kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.labels}'
  ```
  - If missing, edit the Deployment:
    ```bash
    kubectl edit deployment <deployment-name> -n <namespace>
    ```
    Add:
    ```yaml
    spec:
      template:
        metadata:
          labels:
            app: my-app
    ```

##### **Step 2: Create a ClusterIP Service**
- Define a Service to target your pod(s):
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: my-app-service
    namespace: <namespace>
  spec:
    selector:
      app: my-app
    ports:
    - protocol: TCP
      port: 80  # Service port (adjust to your app’s port)
      targetPort: 80  # Pod port
    type: ClusterIP
  ```
- Save as `service.yaml` and apply:
  ```bash
  kubectl apply -f service.yaml
  ```
- Verify:
  ```bash
  kubectl get svc -n <namespace>
  ```
  - Example:
    ```
    NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    my-app-service   ClusterIP   10.96.123.45   <none>        80/TCP    2m
    ```

##### **Step 3: Install an Ingress Controller**
- **Choosing a Controller**: NGINX is common, but Traefik or HAProxy are alternatives.
- **NGINX Options**: The manifest depends on your environment:
  - **Bare-Metal** (e.g., physical servers, VMs):
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
    ```
    - **Purpose**: For clusters without cloud load balancers (e.g., your bare-metal setup).
    - **Exposure**: Uses `NodePort` (e.g., 30080 for HTTP, 30443 for HTTPS).
    - **Version**: Latest from `main` branch (e.g., v1.12.0 or newer as of March 2025).
    - **Pros**: Works out-of-the-box on bare-metal; up-to-date.
    - **Cons**: No external IP; requires node IP access.
  - **Cloud** (e.g., AWS, GKE):
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
    ```
    - **Purpose**: For cloud providers with native load balancers.
    - **Exposure**: Uses `LoadBalancer`, assigning an external IP (e.g., AWS ELB).
    - **Version**: Specific to v1.12.0 (mid-2023 release).
    - **Pros**: Stable; integrates with cloud features.
    - **Cons**: `LoadBalancer` stays `<pending>` on bare-metal; older version.
- **Check Deployment** (Bare-Metal Example):
  ```bash
  kubectl get pods -n ingress-nginx
  ```
  - Example:
    ```
    NAME                                        READY   STATUS    AGE
    ingress-nginx-controller-5d8f7c6b8f-xyz    1/1     Running   5m
    ```
  ```bash
  kubectl get svc -n ingress-nginx
  ```
  - Example:
    ```
    NAME                       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    ingress-nginx-controller   NodePort   10.96.123.46    <none>        80:30080/TCP,443:30443/TCP   5m
    ```
  - **Cloud Note**: If using `cloud/deploy.yaml` on bare-metal, `EXTERNAL-IP` will be `<pending>` unless paired with MetalLB.

##### **Step 4: Create an Ingress Resource**
- Define routing rules:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: my-app-ingress
    namespace: <namespace>
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /  # Optional: rewrite path
  spec:
    rules:
    - http:
        paths:
        - path: /my-app
          pathType: Prefix
          backend:
            service:
              name: my-app-service
              port:
                number: 80
  ```
- Save as `ingress.yaml` and apply:
  ```bash
  kubectl apply -f ingress.yaml
  ```
- **Notes**:
  - `/my-app` routes to `my-app-service:80`.
  - Adjust `port` and `path` to your app (e.g., 5000 for MLflow).

##### **Step 5: Test Access**
- **Internal Test**:
  - From a pod:
    ```bash
    kubectl exec -it <other-pod> -n <namespace> -- curl http://my-app-service:80
    ```
- **External Test**:
  - **Bare-Metal (`NodePort`)**:
    ```bash
    curl http://<node-ip>:30080/my-app
    ```
    - Example: `http://192.168.1.101:30080/my-app`.
  - **Cloud (`LoadBalancer`)**:
    ```bash
    kubectl get ingress -n <namespace>
    ```
    - Look for `ADDRESS` (e.g., `203.0.113.10`).
    ```bash
    curl http://<external-ip>/my-app
    ```

##### **Step 6: Optional - Add Domain and TLS**
- **Domain**:
  - Test with `/etc/hosts`:
    ```
    <node-ip> my-app.example.com
    ```
  - Update Ingress:
    ```yaml
    spec:
      rules:
      - host: my-app.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
    ```
  - Apply:
    ```bash
    kubectl apply -f ingress.yaml
    ```
  - Test:
    ```bash
    curl http://my-app.example.com:30080
    ```

- **TLS**:
  - Create a self-signed cert:
    ```bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=my-app.example.com"
    kubectl create secret tls my-app-tls --cert=tls.crt --key=tls.key -n <namespace>
    ```
  - Update Ingress:
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-app-ingress
      namespace: <namespace>
    spec:
      tls:
      - hosts:
        - my-app.example.com
        secretName: my-app-tls
      rules:
      - host: my-app.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
    ```
  - Test:
    ```bash
    curl --insecure https://my-app.example.com:30443
    ```

---

#### **Troubleshooting**
- **404/Not Found**:
  - Check Ingress:
    ```bash
    kubectl describe ingress my-app-ingress -n <namespace>
    ```
  - Controller logs:
    ```bash
    kubectl logs -n ingress-nginx <ingress-pod>
    ```
- **Service Issues**:
  - Verify endpoints:
    ```bash
    kubectl get endpoints my-app-service -n <namespace>
    ```
- **Firewall** (Bare-Metal)**:
  - Open `NodePort` (e.g., 30080, 30443):
    ```bash
    sudo firewall-cmd --add-port=30080/tcp --permanent
    sudo firewall-cmd --reload
    ```

---

#### **Key Notes**
- **Controller Selection**:
  - **Bare-Metal**: Use `baremetal/deploy.yaml` for `NodePort` (latest version); stable alternative: `controller-v1.12.0/deploy/static/provider/baremetal/deploy.yaml`.
  - **Cloud**: Use `cloud/deploy.yaml` for `LoadBalancer` (v1.12.0 or latest tag); requires cloud integration.
- **Environment Fit**: Bare-metal needs `NodePort` or MetalLB; cloud uses native load balancers.
- **Scalability**: Add paths (e.g., `/app2`) or hosts to the Ingress.
- **Annotations**: Customize with `nginx.ingress.kubernetes.io/*` (e.g., `rewrite-target`).

---

#### **Conclusion**
This guide sets up Ingress for any pod, using NGINX with bare-metal (`NodePort`) or cloud (`LoadBalancer`) options. Deploy a controller matching your environment, create a Service, define Ingress rules, and test access. Adjust ports, paths, or TLS as needed for your app.

Let me know if you need a specific example or further clarification!
