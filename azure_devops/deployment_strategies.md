---

# 📘 Azure Pipeline Deployment Strategies – Detailed Notes

Azure Pipelines supports multiple **deployment strategies** that help you control **how applications are released to environments** (e.g., dev, test, staging, production). The right strategy depends on factors like **downtime tolerance, rollback needs, traffic routing, and risk appetite**.

---

## 1. **RunOnce (Basic Deployment)**

👉 The simplest deployment method.

* Application is deployed **once** to the target environment.
* No fancy traffic routing, no gradual rollout.
* Best for **non-production environments** (Dev, QA, Test).

### Example Use Case:

* Deploying an internal API to a **development environment**.
* No concern about downtime.

### Example in Azure YAML:

```yaml
strategy:
  runOnce:
    deploy:
      steps:
        - script: echo "Deploying app to Dev environment"
```

---

## 2. **Rolling Deployment**

👉 Deploys updates **gradually to subsets of servers/pods** until all are updated.

* Ensures **zero downtime** (old version runs while new one is gradually rolled out).
* Useful in **VMSS (Virtual Machine Scale Sets)** or **Kubernetes clusters**.
* Safer than RunOnce, but rollback may take time.

### Example Use Case:

* Updating a web app hosted in **Azure Kubernetes Service (AKS)**.
* Users continue to access old pods until new ones are ready.

### Key Points:

* Gradual rollout = reduced risk.
* Slower than RunOnce.

### Example in Azure YAML:

```yaml
strategy:
  rolling:
    maxParallel: 2
    preDeploy:
      steps:
        - script: echo "Validating before rolling deployment"
    deploy:
      steps:
        - script: echo "Deploying to rolling batch"
    postDeploy:
      steps:
        - script: echo "Deployment complete"
```

---

## 3. **Canary Deployment**

👉 Deploy new version to a **small subset of users/servers first** (e.g., 5% traffic).

* If stable → gradually increase traffic.
* If issues → rollback quickly.
* Safer for **production environments** with critical workloads.

### Example Use Case:

* Deploying a new feature in an **e-commerce site** → start with 10% users, then 50%, then 100%.

### Key Points:

* Requires **traffic routing support** (e.g., Azure Front Door, Application Gateway, AKS ingress controller).
* Best for reducing blast radius of failures.

### Example in Azure YAML:

```yaml
strategy:
  canary:
    increments: [10, 50, 100]   # Traffic percentages
    preDeploy:
      steps:
        - script: echo "Preparing canary deployment"
    deploy:
      steps:
        - script: echo "Deploying canary version"
    routeTraffic:
      steps:
        - script: echo "Routing traffic to canary"
    postRouteTraffic:
      steps:
        - script: echo "Traffic shifted successfully"
    onFailure:
      steps:
        - script: echo "Rolling back canary deployment"
```

---

## 4. **Blue-Green Deployment**

👉 Maintains **two environments**:

* **Blue (current live)**
* **Green (new release)**
* Deploy new version to **Green**, test it, then **switch traffic** to Green.
* If issues → instantly switch back to Blue.

### Example Use Case:

* Banking/finance app where downtime is **not acceptable**.
* Deploy to Green, validate, then cutover traffic.

### Key Points:

* Zero downtime.
* Requires **infrastructure duplication** (extra cost).
* Switching is fast and safe.

### Example in Azure YAML:

```yaml
strategy:
  blueGreen:
    preDeploy:
      steps:
        - script: echo "Deploying to Green environment"
    deploy:
      steps:
        - script: echo "Deploying app to Green"
    routeTraffic:
      steps:
        - script: echo "Switching traffic to Green"
    postRouteTraffic:
      steps:
        - script: echo "Green is now live"
    onFailure:
      steps:
        - script: echo "Rolling back to Blue"
```

---

## 5. **Feature Flags (Progressive Exposure)**

👉 Not exactly a pipeline strategy, but a **deployment technique**.

* Deploy new code **disabled by default**.
* Enable features gradually using **feature flags** (e.g., LaunchDarkly, Azure App Configuration).

### Example Use Case:

* Release new UI elements to **internal testers first** without redeployment.
* Toggle features on/off instantly.

---

## 📊 Comparison Table

| Strategy      | Zero Downtime | Rollback Speed | Complexity | Cost   | Best For                 |
| ------------- | ------------- | -------------- | ---------- | ------ | ------------------------ |
| RunOnce       | ❌             | Moderate       | Low        | Low    | Dev/Test                 |
| Rolling       | ✅             | Slow           | Medium     | Medium | AKS, VMSS                |
| Canary        | ✅             | Fast           | High       | Medium | Prod apps with high risk |
| Blue-Green    | ✅             | Instant        | High       | High   | Critical prod apps       |
| Feature Flags | ✅             | Instant        | Medium     | Medium | Gradual feature rollout  |

---

## 🔑 Choosing the Right Strategy

* **Dev/Test** → RunOnce
* **Staging/QA** → Rolling
* **Production (low-risk)** → Canary
* **Production (mission-critical)** → Blue-Green
* **Feature rollout without redeployment** → Feature Flags

---

⚡ Example Real-World Flow:

1. **Dev** → RunOnce (quick deploy)
2. **Staging** → Rolling (stability check)
3. **Prod** → Canary (start with 10%) → Blue-Green (final cutover)
4. Use **Feature Flags** for experimental features

---
