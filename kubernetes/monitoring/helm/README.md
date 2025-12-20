Got it 👍 Let’s build a **step-by-step detailed guide** for installing the **Prometheus Stack** with **Helm** on Minikube (or any Kubernetes cluster). This guide covers: setup, installation, verifying, accessing the UI, and cleaning up.

---

# 📘 Guide: Install Prometheus Stack with Helm

The **Prometheus Stack** (also known as `kube-prometheus-stack`) includes:

* **Prometheus** (metrics collection)
* **Alertmanager** (alerts handling)
* **Node Exporter** (node metrics)
* **Kube State Metrics** (Kubernetes object metrics)
* **Grafana** (dashboards)

---

## 1️⃣ Prerequisites

* A running Minikube cluster:

  ```bash
  minikube start --memory=4096 --cpus=2
  ```
* Helm installed:

  ```bash
  helm version
  ```

  If not installed → [Helm installation guide](https://helm.sh/docs/intro/install/).

---

## 2️⃣ Add Prometheus Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

## 3️⃣ Create a Monitoring Namespace

```bash
kubectl create namespace monitoring
```

---

## 4️⃣ Install kube-prometheus-stack

This chart includes Prometheus, Grafana, Alertmanager, and exporters all together.

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

* `prometheus` → release name
* `prometheus-community/kube-prometheus-stack` → chart name
* `-n monitoring` → install into `monitoring` namespace

---

## 5️⃣ Verify Installation

Check pods:

```bash
kubectl get pods -n monitoring
```

You should see something like:

```
prometheus-kube-prometheus-operator-xxxx
prometheus-kube-state-metrics-xxxx
prometheus-prometheus-node-exporter-xxxx
prometheus-prometheus-pushgateway-xxxx
prometheus-grafana-xxxx
prometheus-prometheus-xxxx
prometheus-alertmanager-xxxx
```

---

## 6️⃣ Access Prometheus and Grafana

### Option 1: Port-forward (simple for Minikube)

**Prometheus:**

```bash
kubectl port-forward -n monitoring deploy/prometheus-kube-prometheus-prometheus 9090
```

👉 Open [http://localhost:9090](http://localhost:9090)

**Grafana:**

```bash
kubectl port-forward -n monitoring deploy/prometheus-grafana 3000
```

👉 Open [http://localhost:3000](http://localhost:3000)

Login credentials (default):

* **User:** `admin`
* **Password:** `prom-operator`

(You can also fetch the password dynamically with:)

```bash
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

---

### Option 2: Use Minikube service (opens browser directly)

```bash
minikube service prometheus-grafana -n monitoring
minikube service prometheus-kube-prometheus-prometheus -n monitoring
```

---

## 7️⃣ Explore Dashboards

* In **Grafana**, go to **Dashboards → Manage**
* Default dashboards for Kubernetes Nodes, Pods, and Cluster will already be imported.
* Prometheus UI lets you query metrics (e.g., `node_cpu_seconds_total`, `kube_pod_info`).

---

## 8️⃣ Customize Installation (Optional)

You can customize with a `values.yaml` file. Example:

```yaml
grafana:
  adminPassword: "MySecurePassword"
  service:
    type: NodePort
    nodePort: 32000
prometheus:
  prometheusSpec:
    retention: 7d
    scrapeInterval: "30s"
```

Install with:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

---

## 9️⃣ Uninstalling / Cleanup

To remove the entire Prometheus stack:

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

---

## 🔎 Example Workflow

```bash
# Add repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create namespace
kubectl create namespace monitoring

# Install
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Verify
kubectl get pods -n monitoring

# Port-forward Grafana
kubectl port-forward -n monitoring deploy/prometheus-grafana 3000

# Login Grafana (admin / prom-operator)
```

---

✅ Now you’ll have a **full monitoring stack (Prometheus + Grafana + Alertmanager + Exporters)** running in your Minikube.

---

Would you like me to also write a **set of common PromQL queries** you can try right after this installation (like CPU usage, pod restarts, memory usage) so you can play around in Grafana and Prometheus?
