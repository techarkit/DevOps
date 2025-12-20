# Monitoring Setup Guide

## Installing Prometheus and Grafana

1. Add Helm repository:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

2. Install Prometheus:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -f prometheus-values.yaml
```

- Verify that all pods has been created:

```bash
kubectl get all
```

3. Access Grafana:

```bash
kubectl port-forward svc/prometheus-grafana 3000:80
```

Default credentials:

- Username: admin
- Password: prom-operator

## Useful Dashboards

- Node Exporter Full (ID: 1860)
- Kubernetes Cluster Monitoring (ID: 315)
- Kubernetes Pod Monitoring (ID: 6417)

## Alert Configuration

See `prometheus-values.yaml` for alert configuration examples.
