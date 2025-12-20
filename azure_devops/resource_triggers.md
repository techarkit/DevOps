# 📘 Resource Triggers
---

## 1. 🔹 What is a Pipeline Resource?

* A **pipeline resource** represents another pipeline in your project.
* It allows your current pipeline to be triggered automatically or consume artifacts from that pipeline.
* Useful for **chaining pipelines** (e.g., Infra → App).

---

## 2. 🔹 Why Use Pipeline Resource Triggers?

* **Separation of concerns**: Keep infra and app pipelines independent but connected.
* **Dependency ordering**: Ensure infra is deployed before app code.
* **Reusability**: Multiple pipelines can consume the same upstream pipeline.
* **Granular triggers**: You can filter by branches, pipeline runs, or trigger manually.

---

## 3. 🔹 Syntax Overview

```yaml
resources:
  pipelines:
    - pipeline: <alias>
      source: <pipeline name>
      trigger: <true | false | filters>
```

* **`pipeline`** → Alias you define (used inside jobs/stages).
* **`source`** → The **pipeline name** in Azure DevOps (not the YAML filename).
* **`trigger`**:

  * `true` → Run automatically on *any* completion of the source pipeline.
  * `false` → Do not auto-run; pipeline can still be triggered manually with a pipeline resource.
  * Branch filters → Run only when source pipeline is triggered on specific branches.

---

## 4. 🔹 Example Scenarios

### ✅ (a) Run App after Infra (any branch)

```yaml
resources:
  pipelines:
    - pipeline: infraPipeline
      source: InfraPipeline
      trigger: true
```

→ Every successful run of **InfraPipeline** triggers this pipeline.

---

### ✅ (b) Run App only when Infra runs on `main`

```yaml
resources:
  pipelines:
    - pipeline: infraPipeline
      source: InfraPipeline
      trigger:
        branches:
          include:
            - main
```

---

### ✅ (c) Manual dependency (no auto trigger)

```yaml
resources:
  pipelines:
    - pipeline: infraPipeline
      source: InfraPipeline
      trigger: none
```

→ You can **manually run** this pipeline and pick an infra run to consume artifacts from.

---

### ✅ (d) Using Infra artifacts in App

If Infra publishes an artifact (e.g., ARM/Bicep outputs), you can use it in App pipeline:

```yaml
steps:
- download: infraPipeline
  artifact: drop
```

---

## 5. 🔹 Important Points & Gotchas

1. **Pipeline name vs file name**

   * `source:` must match the pipeline’s **name in Azure DevOps UI**, not the YAML file.
   * You can rename pipelines under **Pipelines → Edit → Name**.

2. **Branch filters**

   * Filters apply to the branch of the **upstream pipeline**.
   * If InfraPipeline ran on `dev`, the App pipeline won’t trigger unless `dev` is included.

3. **Artifacts**

   * Pipeline resources can bring in published artifacts (useful for builds → deploys).

4. **Cross-project triggers**

   * Supported, but you must specify `project:` in the resource definition.

   ```yaml
   resources:
     pipelines:
       - pipeline: infraPipeline
         project: InfraProject
         source: InfraPipeline
         trigger: true
   ```

5. **Security**

   * Permissions may be required for one pipeline to access another’s artifacts.
   * Set under **Project Settings → Pipelines → Settings → Protected Resources**.

---

## 6. 🔹 Best Practices

* **Use separate pipelines** for infra and app for clarity.
* **Use branch filters** to avoid unexpected triggers (e.g., don’t deploy app when infra runs on feature branches).
* **Publish artifacts** from Infra pipeline to pass outputs cleanly.
* **Document dependencies** so teammates understand the chain.
* **Consider environments**: Use `environment:` in jobs to track deployments across pipelines.

---

✅ This setup is the **recommended way** in Azure DevOps when you want to chain pipelines.

---

## Github Actions Equivalent:

👉 In GitHub Actions, there is no direct equivalent of resources.pipelines — instead, we achieve the same effect with workflow_run triggers.
