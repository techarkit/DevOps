### 📄 *Learning GitHub Actions from Scratch*

# 🚀 GitHub Actions Learning Guide

This repository is a structured roadmap to learn GitHub Actions — GitHub's native CI/CD platform. It covers the fundamentals, advanced topics, real-world patterns, and infrastructure integration (Ansible, Terraform, etc.).

---

## 📚 Table of Contents

### 🔰 1. Basics of GitHub Actions
- [ ] What is GitHub Actions?
- [ ] Key Components: `workflow`, `job`, `step`
- [ ] Events and triggers (`push`, `pull_request`, `schedule`, `workflow_dispatch`)
- [ ] `runs-on` and GitHub-hosted runners
- [ ] Writing your first workflow (`.github/workflows/ci.yml`)
- [ ] Using `run` vs `uses` (Shell commands vs Action steps)

---

### 🧪 2. Workflow Syntax & Features
- [ ] Environment variables (`env`)
- [ ] Conditional execution (`if`)
- [ ] Job dependencies (`needs`)
- [ ] Matrix builds
- [ ] Artifacts and caching
- [ ] Reusable workflows with `workflow_call`

---

### 🔁 3. Real-World Workflows
- [ ] CI for Python/Node/Go projects
- [ ] Linting & testing automation
- [ ] Docker image build and push
- [ ] Versioning and release tagging
- [ ] Notification integrations (Slack, email)

---

### 🧩 4. GitHub Environments
- [ ] Creating `development`, `staging`, `production` environments
- [ ] Using `environment:` key in jobs
- [ ] Environment-specific secrets
- [ ] Deployment protection rules and approvals
- [ ] Showing deployment status in PRs

---

### 🧰 5. Secrets & Security
- [ ] Setting up secrets at repo/org/environment level
- [ ] Masking and safe usage of secrets
- [ ] Using GitHub OIDC with cloud providers (AWS, Azure)

---

### ⚙️ 6. Actions & Marketplace
- [ ] What are Actions?
- [ ] Using public actions from the GitHub Marketplace
- [ ] Writing your own custom action (Docker / Composite)
- [ ] Publishing and versioning your own action

---

### 🧱 7. Infrastructure Integration
- [ ] Running Ansible playbooks from workflows
- [ ] Using Terraform with GitHub Actions
- [ ] Deploying to:
  - [ ] AWS (EC2, Lambda, ECS, S3)
  - [ ] Azure (App Service, VMs)
  - [ ] Kubernetes (k8s manifests / Helm)

---

### 📦 8. Advanced Topics
- [ ] Self-hosted runners (Linux/Windows)
- [ ] Job concurrency and locking
- [ ] Manual triggers (`workflow_dispatch` inputs)
- [ ] Scheduled workflows (cron jobs)
- [ ] Dependency caching (`actions/cache`)
- [ ] Error handling and retries

---

### 📈 9. Monitoring & Optimization
- [ ] Workflow insights & usage metrics
- [ ] Reducing workflow time
- [ ] Debugging workflows (`ACTIONS_STEP_DEBUG`)
- [ ] Secrets audit and security best practices

---

### 📁 10. Bonus Projects (Practice Ideas)
- [ ] Full CI/CD for a Flask/Django app
- [ ] Deploy static site to GitHub Pages
- [ ] Auto-bump versions and changelogs
- [ ] Integrate with Ansible for zero-downtime deploys
- [ ] GitOps-style deployment using Actions

---

## 🧠 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Awesome Actions List](https://github.com/sdras/awesome-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

---

## 📝 Progress Tracker

You can mark checkboxes `[x]` as you complete each topic or link each item to a Markdown note in this repo with examples and explanation.

Happy learning! 🚀


---
