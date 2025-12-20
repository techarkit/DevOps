# NGINX Deployment Guide for Kubernetes

## Prerequisites
- A running Kubernetes cluster
- kubectl configured and working
- Verify cluster readiness:
  ```bash
  kubectl get nodes -o wide
  kubectl get pods -A
  kubectl cluster-info
  ```

## Basic Deployment Steps

### 1. Create Namespace (Optional but recommended)
```bash
# Create namespace
kubectl create namespace nginx-demo

# Set current context to the new namespace
kubectl config set-context --current --namespace=nginx-demo

# List all namespaces
kubectl get namespaces
```


### 2. Create a Deployment with Resource Limits
```yaml
// filepath: nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: nginx-demo
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
```

### 3. Create ConfigMap for NGINX Configuration
```yaml
// filepath: nginx-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nginx-demo
data:
  nginx.conf: |
    server {
      listen 80;
      server_name localhost;
      location / {
        root /usr/share/nginx/html;
        index index.html;
      }
    }
```

### 4. Create Service with Multiple Types
```yaml
// filepath: nginx-services.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
  namespace: nginx-demo
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
  namespace: nginx-demo
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30007
```

### 5. Deploy Everything
```bash
kubectl apply -f nginx-config.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-services.yaml
```

## Monitoring and Management Commands

### Deployment Management
```bash
# Watch deployment status
kubectl get deployments -n nginx-demo -w

# Check deployment rollout status
kubectl rollout status deployment/nginx-deployment -n nginx-demo

# View deployment history
kubectl rollout history deployment/nginx-deployment -n nginx-demo

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5 -n nginx-demo
```

### Pod Management
```bash
# Get pods with detailed info
kubectl get pods -n nginx-demo -o wide

# Watch pod status
kubectl get pods -n nginx-demo -w

# Get pod logs
kubectl logs -f -l app=nginx -n nginx-demo

# Execute commands in pod
kubectl exec -it $(kubectl get pod -l app=nginx -o jsonpath="{.items[0].metadata.name}" -n nginx-demo) -n nginx-demo -- /bin/bash
```

### Service Management
```bash
# List all services
kubectl get svc -n nginx-demo

# Get service endpoints
kubectl get endpoints -n nginx-demo

# Test service (from within cluster)
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -n nginx-demo -- /bin/bash
curl nginx-clusterip
```

## Cleanup
```bash
# Delete all resources in namespace
kubectl delete namespace nginx-demo

# Or delete individual resources
kubectl delete -f nginx-deployment.yaml
kubectl delete -f nginx-services.yaml
kubectl delete -f nginx-config.yaml
```

## Best Practices

1. **Resource Management**
   - Always set resource requests and limits
   - Monitor resource usage with `kubectl top pods/nodes`

2. **Health Checks**
   - Implement both liveness and readiness probes
   - Set appropriate timeout values

3. **Security**
   - Use namespaces for isolation
   - Apply RBAC policies
   - Use network policies

4. **High Availability**
   - Use pod anti-affinity for pod distribution
   - Set appropriate pod disruption budgets
   - Configure horizontal pod autoscaling

5. **Monitoring**
   - Set up prometheus/grafana for metrics
   - Configure proper logging
   - Use labels for better resource tracking

6. **Updates and Rollbacks**
   - Use rolling updates strategy
   - Set appropriate update parameters
   - Keep deployment history for rollbacks