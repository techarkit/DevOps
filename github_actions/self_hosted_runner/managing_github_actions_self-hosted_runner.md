
## 📁 What Happens in the `_work` Directory?

When a job runs on a self-hosted runner:

- The runner **downloads your repository** into:
  ```
  /home/github-runner/actions-runner/_work/<repo-name>/<repo-branch-or-sha>
  ```
- This is called the **"workspace"**.
- Inside `_work`, you'll see:
  ```
  _work/
    <repo-name>/
      _temp/         # temporary files for the job
      _tool/         # downloaded action tools
      <job folder>/  # actual repo checkout
  ```

---

## 🧹 Does the Runner Auto-Clean?

### ✅ Short answer: **Yes, but not completely.**

By default:
- The **repo folder is reused** across jobs and builds, **not deleted after every job**.
- Temporary directories like `_temp` are **cleaned automatically** after each job.
- If you use `actions/checkout`, it **fetches latest changes** and resets working directory, but old files (not in repo) may remain.

This is different from GitHub-hosted runners, which are clean, ephemeral VMs.

---

## ⚠️ What Does This Mean for You?

If you're using a **self-hosted runner**, the following applies:

### 1. **Artifacts or Cache May Accumulate**
Over time, your disk can fill up with:
- Old build outputs
- Logs
- Downloaded tools
- Leftover repo files

### 2. **Manual Cleanup May Be Required**
Best practice is to add cleanup either in the job or a scheduled cron.

---

## ✅ Best Practices for Self-Hosted Runner Cleanup

### 🔹 Option 1: Clean workspace after each job
Add a final step to remove everything except `_tool` and `_work`:
```yaml
- name: Cleanup workspace
  if: always()
  run: |
    sudo rm -rf "$GITHUB_WORKSPACE"/*
```

> **`$GITHUB_WORKSPACE`** points to the job's checkout dir, not the root `_work` dir.

---

### 🔹 Option 2: Use a Scheduled GitHub Action (weekly/daily cleanup)
Create a scheduled job in `.github/workflows/cleanup.yml`:

```yaml
name: Cleanup Workspace

on:
  schedule:
    - cron: "0 3 * * 0"  # Every Sunday at 3 AM

jobs:
  cleanup:
    runs-on: self-hosted
    steps:
      - name: Remove old repo folders
        run: |
          find /home/github-runner/actions-runner/_work/ -mindepth 1 -maxdepth 1 -mtime +7 -exec rm -rf {} \;
```

---

### 🔹 Option 3: Use Runner Hooks (Advanced)

You can define **custom hooks** in the runner's directory to auto-clean before/after jobs:

```bash
actions-runner/.github/hooks/
├── pre-job.sh
├── post-job.sh
```

E.g., `post-job.sh` could contain:
```bash
#!/bin/bash
rm -rf "$RUNNER_WORKSPACE/*"
```

Make it executable:
```bash
chmod +x actions-runner/.github/hooks/post-job.sh
```

---

## Summary

| Aspect            | GitHub-hosted Runners      | Self-hosted Runners         |
|-------------------|----------------------------|-----------------------------|
| Clean workspace   | Yes (new VM per job)       | ❌ No (manual cleanup needed) |
| Repo reuse        | ❌                          | ✅                          |
| Cleanup needed    | No                         | ✅ Recommended              |
| Custom hooks      | N/A                        | ✅ Supported                |

---
