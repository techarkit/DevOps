# Kubernetes Monitoring Stack Implementation Guide

## Step 1: Prerequisites Verification
```bash
# Check Kubernetes version
kubectl version

# Verify cluster access
kubectl cluster-info

# Check storage class availability
kubectl get sc
```

## Step 2: Clone and Prepare
```bash
git clone https://github.com/jahangir842/kubernetes-notes.git
cd monitoring

# Create namespace and switch context
kubectl create namespace monitoring
kubectl config set-context --current --namespace=monitoring


# Verify namespace and context
kubectl config get-contexts
```

## Step 3: Storage Setup
```bash
# Verify storage class exists (should show local-path)
kubectl get sc

# Create PVCs
kubectl apply -f storage/monitoring-storage.yaml

# Verify PVCs are created
kubectl get pvc -n monitoring
```

## Step 4: Deploy Components

### 4.1 Prometheus Setup
```bash
# 1. Create RBAC
kubectl apply -f prometheus/prometheus-rbac.yaml

# 2. Create alert and recording rules
kubectl apply -f prometheus/rules/node-alerts.yaml
kubectl apply -f prometheus/rules/recording-rules.yaml

# 3. Create Prometheus configuration
kubectl apply -f prometheus/prometheus-configmap.yaml

# 4. Deploy Prometheus
kubectl apply -f prometheus/prometheus-deployment.yaml
kubectl apply -f prometheus/prometheus-service.yaml

# 5. Verify Prometheus deployment
kubectl get pods -l app=prometheus
kubectl get svc prometheus
```

### 4.2 AlertManager Setup
```bash
# 1. Create AlertManager config
# First, edit alertmanager/alertmanager-configmap.yaml to set up your notifications

# 2. Apply AlertManager configurations
kubectl apply -f alertmanager/alertmanager-configmap.yaml
kubectl apply -f alertmanager/alertmanager-deployment.yaml
kubectl apply -f alertmanager/alertmanager-service.yaml

# 3. Verify AlertManager
kubectl get pods -l app=alertmanager
kubectl get svc alertmanager
```

### 4.3 Grafana Setup
```bash
# 1. Deploy Grafana
kubectl apply -f grafana/grafana-deployment.yaml
kubectl apply -f grafana/grafana-service.yaml

# 2. Verify Grafana
kubectl get pods -l app=grafana
kubectl get svc grafana
```

## Step 5: Access Services

Get your node IP:
```bash
kubectl get nodes -o wide
```

Services are available at:
- Prometheus: `http://<node-ip>:30090`
- AlertManager: `http://<node-ip>:30093`
- Grafana: `http://<node-ip>:30300`
  - Default credentials: admin/admin

## Step 6: Post-Installation Configuration

### 6.1 Grafana Dashboard Setup
1. Log in to Grafana
2. Add Prometheus data source:
   - URL: `http://prometheus:9090`
   - Save & Test
3. Import dashboards:
   - Node Exporter: 1860
   - Kubernetes: 315
   - Pod Metrics: 6417

### 6.2 AlertManager Configuration
1. Edit `alertmanager/alertmanager-configmap.yaml`:
   ```yaml
   email_configs:
     - to: 'your-email@example.com'
   slack_configs:
     - api_url: 'your-slack-webhook'
   ```
2. Apply changes:
   ```bash
   kubectl apply -f alertmanager/alertmanager-configmap.yaml
   kubectl rollout restart deployment/alertmanager
   ```

## Step 7: Verification

### 7.1 Check Components
```bash
# Check all pods are running
kubectl get pods

# Check services
kubectl get svc

# Check PVCs are bound
kubectl get pvc
```

### 7.2 Test Monitoring
1. Access Prometheus UI:
   - Run a test query: `up`
   - Check targets: Status > Targets
2. Access AlertManager UI:
   - Verify configuration
   - Check alert routes
3. Access Grafana:
   - Verify data source connection
   - Check dashboard data flow

## Troubleshooting

### Common Issues and Solutions

1. PVC Binding Issues:
```bash
kubectl describe pvc prometheus-pvc
kubectl describe pvc grafana-pvc
```

2. Pod Startup Issues:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

3. Service Access Issues:
```bash
# Test service endpoints
kubectl get endpoints

# Check node ports
kubectl get svc -o wide
```

## Troubleshooting Storage

### Storage Class Configuration
The cluster uses the `local-path` StorageClass which has the following configuration:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

Key points about this configuration:
- **Provisioner**: `rancher.io/local-path` - Manages local storage on nodes
- **ReclaimPolicy**: `Delete` - Storage is deleted when PVC is deleted
- **VolumeBindingMode**: `WaitForFirstConsumer` - PV is created only when a pod using the PVC is scheduled


Important: Due to the `WaitForFirstConsumer` binding mode, PVs will only be created after pods are scheduled.

## Storage Management

### When Data Exceeds PVC Capacity
When data approaches or exceeds PVC capacity:
1. Pod will fail to write new data
2. Prometheus/Grafana may become read-only or crash
3. No automatic expansion available with local-path storage

### Prevention and Solutions:
```bash
# Monitor PV usage
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,USED:.status.capacity

# Check actual usage on node
ssh <node-name> "df -h /var/lib/rancher/k3s/storage/pvc-*"

# Implement cleanup:
- Set Prometheus retention in prometheus-configmap.yaml
- Enable Grafana's built-in cleanup jobs
- Monitor storage alerts
```

### Emergency Actions:
1. Temporary: Delete old data
2. Long-term: Migrate to new PVC
3. Prevention: Set up monitoring alerts

## Maintenance

### Backup
```bash
# Create backup directory
mkdir -p /path/to/backups

# Backup Prometheus data
kubectl exec -n monitoring $(kubectl get pods -l app=prometheus -o jsonpath='{.items[0].metadata.name}') \
  -- tar czf - /prometheus > /path/to/backups/prometheus-$(date +%Y%m%d).tar.gz

# Backup Grafana
kubectl exec -n monitoring $(kubectl get pods -l app=grafana -o jsonpath='{.items[0].metadata.name}') \
  -- tar czf - /var/lib/grafana > /path/to/backups/grafana-$(date +%Y%m%d).tar.gz
```

### Updates
```bash
# Update images
kubectl set image deployment/prometheus prometheus=prom/prometheus:v2.45.0
kubectl set image deployment/grafana grafana=grafana/grafana:9.5.3
kubectl set image deployment/alertmanager alertmanager=prom/alertmanager:v0.25.0
```

## Cleanup Instructions

### Option 1: Delete Everything in One Command
```bash
# Delete all resources in monitoring namespace
kubectl delete namespace monitoring
```

### Option 2: Delete Components Individually
Follow this order to safely remove components:

```bash
# 1. Delete Grafana
kubectl delete -f grafana/
kubectl delete pvc grafana-pvc -n monitoring

# 2. Delete AlertManager
kubectl delete -f alertmanager/

# 3. Delete Prometheus
kubectl delete -f prometheus/prometheus-service.yaml
kubectl delete -f prometheus/prometheus-deployment.yaml
kubectl delete -f prometheus/prometheus-configmap.yaml
kubectl delete -f prometheus/rules/
kubectl delete -f prometheus/prometheus-rbac.yaml
kubectl delete pvc prometheus-pvc -n monitoring

# 4. Delete Storage Resources
kubectl delete -f storage/monitoring-storage.yaml

# 5. Finally, delete the namespace
kubectl delete namespace monitoring

# 6. Verify cleanup
kubectl get all -n monitoring
kubectl get pvc -n monitoring
kubectl get configmaps -n monitoring
kubectl get secrets -n monitoring
```

### Optional: Clean Local Storage
If using local-path provisioner, clean up the storage directories on your nodes:
```bash
# On each node where PVs were created (requires SSH access):
sudo rm -rf /var/lib/rancher/k3s/storage/pvc-*
```

Note: Replace the storage path according to your local-path provisioner configuration.

## Storage Information

### Local-Path Storage Location
By default, Rancher's local-path provisioner creates persistent volumes in:
```bash
# On each node:
/var/lib/rancher/k3s/storage/

# The full path to a specific PV will look like:
/var/lib/rancher/k3s/storage/pvc-{UUID}/

# To list all local PVs:
ls /var/lib/rancher/k3s/storage/
```

Note: The storage path might be different if you've customized the local-path provisioner configuration.
