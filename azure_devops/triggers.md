# 🔹 Azure Pipelines: `trigger` vs `pr`

### 1. `trigger:`

* Runs pipeline on **branch commits/pushes**.
* Example: push to `main` → pipeline runs.

### 2. `pr:`

* Runs pipeline on **pull request events** (create/update PR).
* Example: open/update PR into `main` → pipeline runs.

### 3. `batch: true`

* Avoids redundant runs.
* If multiple commits are pushed while a run is active, only the **latest commit** runs after the current build finishes.

---

### ✅ Example YAML

```yaml
trigger:
  branches:
    include:
      - main
      - develop
  batch: true   # optimize branch pushes

pr:
  branches:
    include:
      - main
      - develop
  batch: true   # optimize pull requests
```

---

**In this case:**

- If someone opens a PR targeting main → pipeline runs.
- If someone opens a PR targeting develop → pipeline runs.
- PRs targeting other branches won’t trigger the pipeline.

### 📊 Quick Comparison

| Setting   | When it Runs                | Use Case                       |
| --------- | --------------------------- | ------------------------------ |
| `trigger` | On branch commit/push       | CI builds on main/dev branches |
| `pr`      | On pull request open/update | Validate PRs before merging    |
| `batch`   | Runs only latest commit     | Save time & resources          |

---


# 🚀 Azure DevOps YAML Triggers – Cheat Sheet

---

## 🔹 1. **Continuous Integration (CI) Trigger** – Run on branch push

Automatically runs when commits are pushed to specific branches.

```yaml
trigger:
- main    # Only main branch
```

👉 Use for automatic builds/deployments after each commit.

---

## 🔹 2. **Branch Filters** – Control which branches trigger

Specify `include` and `exclude` patterns.

```yaml
trigger:
  branches:
    include:
      - main
      - release/*
    exclude:
      - experimental/*
```

✅ Common for `main`, `develop`, or `release/*` branches.

---

## 🔹 3. **Path Filters** – Run only on file/folder changes

Limit CI runs to specific paths.

```yaml
trigger:
  branches:
    include: [main]
  paths:
    include: [src/]
    exclude: [docs/]
```

✅ Helps monorepos avoid triggering builds for docs or unrelated changes.

---

## 🔹 4. **Tag Filters** – Trigger on Git tags

Run pipelines on tag creation.

```yaml
trigger:
  tags:
    include: [v*]
    exclude: [test-*]
```

✅ Useful for release pipelines (e.g., versioned tags `v1.0.0`).

---

## 🔹 5. **Batching Builds** – Reduce duplicate runs

Combine multiple commits into one run.

```yaml
trigger:
  batch: true
```

✅ Helpful when many commits are pushed quickly.

---

## 🔹 6. **Pull Request (PR) Trigger** – Validate PRs

Runs when a PR is opened or updated.

```yaml
pr:
  branches:
    include: [main]
  paths:
    include: [bicep/**]
```

✅ Ensures validation/testing before merging.

---

## 🔹 7. **Scheduled Trigger** – Run on a timer (cron)

Runs pipelines at defined times (UTC).

```yaml
schedules:
- cron: "0 2 * * *"     # Daily 2 AM UTC
  displayName: Nightly Build
  branches:
    include: [main]
  always: true           # Run even if no changes
```

✅ Great for nightly builds, cleanup jobs, or infra drift checks.

---

## 🔹 8. **Pipeline Completion Trigger** – Chain pipelines

Trigger one pipeline when another finishes.

```yaml
resources:
  pipelines:
  - pipeline: BuildPipeline
    source: MyApp-Build
    trigger:
      branches:
        include: [main]
```

✅ Use for build → test → deploy workflows.

---

## 🔹 9. **Repository Resource Trigger** – Multi-repo setup

Trigger pipelines when another repo changes.

```yaml
resources:
  repositories:
  - repository: tools
    type: git
    name: ProjectX/tools
    trigger:
      branches:
        include: [main]
```

✅ Useful if your project depends on shared code/tools.

---

## 🔹 10. **Manual Trigger (No CI)** – Run only on demand

Disable auto triggers so runs must be started manually (UI/API).

```yaml
trigger: none
pr: none
```

✅ Perfect for release pipelines or controlled deployments.

---

## 🔹 11. **Manual Parameters** – Customize manual runs

Add runtime parameters when manually starting pipelines.

```yaml
parameters:
- name: environment
  type: string
  default: dev
  values: [dev, prod]
```

✅ Useful for selecting environments (e.g., Dev vs. Prod).

---

## ✅ Quick Reference Table

| Trigger Type            | Description / Use Case                                 |
| ----------------------- | ------------------------------------------------------ |
| **branches**            | Restrict CI to certain branches (`main`, `release/*`). |
| **paths**               | Run only if certain files/folders change.              |
| **tags**                | Run on Git tags (e.g., releases, hotfixes).            |
| **batch**               | Cancel intermediate runs; only latest commit runs.     |
| **pr**                  | Validate PRs before merge.                             |
| **schedules**           | Time-based (cron) triggers (nightly, weekly, etc.).    |
| **pipeline completion** | Chain pipelines together.                              |
| **repository resource** | Trigger on changes in another repo.                    |
| **manual (none)**       | Run only when started manually.                        |
| **manual w/parameters** | Add flexibility for environments or options.           |

---
