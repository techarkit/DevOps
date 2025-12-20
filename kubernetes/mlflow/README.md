# MLflow on Kubernetes

This setup provides an MLflow tracking server with PostgreSQL backend running on Kubernetes.

## Prerequisites

- Kubernetes cluster
- kubectl configured
- MLflow image (mlflow-with-psycopg2:v2.20.3) available in your registry

### Step 1: Create namespace

1. Create and activate namespace:
```bash
kubectl create namespace mlflow
kubectl config set-context --current --namespace=mlflow

# Verify active namespace
kubectl config get-contexts
# The active context should show mlflow as the namespace
```

---

### Step 2: Create New YAML Files

#### 1. **Postgres PersistentVolume and PersistentVolumeClaim**
File: `postgres-pv-pvc.yaml`
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data/postgres"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: mlflow
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

#### 2. **MLflow PersistentVolume and PersistentVolumeClaim**
File: `mlflow-pv-pvc.yaml`
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mlflow-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data/mlflow"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mlflow-pvc
  namespace: mlflow
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

#### 3. **Postgres Deployment, Service, and ConfigMap**
File: `postgres-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: mlflow
spec:
  selector:
    matchLabels:
      app: postgres
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        resources:
          limits:
            memory: "1Gi"
            cpu: "500m"
          requests:
            memory: "512Mi"
            cpu: "250m"
        env:
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          value: "pakistan"
        - name: POSTGRES_DB
          value: "mlflowdb"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: init-script
          mountPath: /docker-entrypoint-initdb.d
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
      - name: init-script
        configMap:
          name: postgres-config
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: mlflow
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: mlflow
data:
  init.sql: |
    CREATE DATABASE mlflowdb;
    \c mlflowdb;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

#### 4. **MLflow Deployment and Service**
File: `mlflow-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
  namespace: mlflow
spec:
  selector:
    matchLabels:
      app: mlflow
  replicas: 1
  template:
    metadata:
      labels:
        app: mlflow
    spec:
      containers:
      - name: mlflow
        image: jahangir842/mlflow-with-psycopg2:v2.20.3
        resources:
          limits:
            memory: "1Gi"  # Increased from 512Mi
            cpu: "500m"
          requests:
            memory: "512Mi"  # Increased from 256Mi
            cpu: "250m"
        ports:
        - containerPort: 5000
        command:
        - mlflow
        - server
        - --host
        - 0.0.0.0
        - --port
        - "5000"
        - --backend-store-uri
        - postgresql://admin:pakistan@postgres:5432/mlflowdb
        - --default-artifact-root
        - file:///mlflow/artifacts
        readinessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
        volumeMounts:
        - name: mlflow-artifacts
          mountPath: /mlflow/artifacts
      volumes:
      - name: mlflow-artifacts
        persistentVolumeClaim:
          claimName: mlflow-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mlflow
  namespace: mlflow
spec:
  type: NodePort
  selector:
    app: mlflow
  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30500

```

---

### Step 3: Apply the New YAML Files

1. **Ensure Host Paths Exist**:
   On your cluster nodes, create the directories:
   ```bash
   sudo mkdir -p /mnt/data/mlflow /mnt/data/postgres
   sudo chmod -R 777 /mnt/data/mlflow /mnt/data/postgres  # Adjust permissions as needed
   ```

2. **Apply the YAML Files**:
   ```bash
   kubectl apply -f postgres-pv-pvc.yaml
   kubectl apply -f mlflow-pv-pvc.yaml
   kubectl apply -f postgres-deployment.yaml
   kubectl apply -f mlflow-deployment.yaml
   ```

---

### Step 4: Verify the Setup

1. **Check Pods**:
   ```bash
   kubectl get pods -n mlflow -o wide
   ```
   - Expected: Both `mlflow` and `postgres` pods in `Running` state.

2. **Check PVCs**:
   ```bash
   kubectl get pvc -n mlflow
   ```
   - Expected:
     - `mlflow-pvc`: `Bound` to `mlflow-pv`.
     - `postgres-pvc`: `Bound` to `postgres-pv`.

3. **Check PVs**:
   ```bash
   kubectl get pv
   ```
   - Expected:
     - `mlflow-pv`: `Bound` to `mlflow/mlflow-pvc`.
     - `postgres-pv`: `Bound` to `mlflow/postgres-pvc`.

4. **Check Services**:
   ```bash
   kubectl get svc -n mlflow -o wide
   ```
   - Expected:
     - `mlflow`: `ClusterIP` with port `5000:30500/TCP`.
     - `postgres`: `ClusterIP` with port `5432`.

5. **Check Logs**:
   ```bash
   kubectl logs -f deployment/postgres -n mlflow
   kubectl logs -f deployment/mlflow -n mlflow
   ```
   - Expected:
     - Postgres: `database system is ready to accept connections`.
     - MLflow: No `Connection timed out` or `No route to host` errors.

6. **Test Connectivity**:
   ```bash
   kubectl exec -it <mlflow-pod-name> -n mlflow -- bash
   ```
   - Inside:
     ```bash
     apt-get update && apt-get install -y netcat
     nc -zv <postgres-pod-ip> 5432
     nc -zv postgres 5432
     ```

7. **Access MLflow UI**:
   - Get node IP:
     ```bash
     kubectl get nodes -o wide
     ```
   - Open: `http://<node-ip>:30500`

---

### Notes
- **Readiness Probe**: Added to MLflow to ensure it’s only `Ready` when the server is up.
- **Namespace**: All resources are in `mlflow`; ensure this namespace exists (`kubectl create namespace mlflow` if needed).
- **Networking**: If `No route to host` reoccurs, we’ll debug Calico after confirming the pods run.

Please apply these files and share the outputs from the verification steps above. Let me know how it goes!