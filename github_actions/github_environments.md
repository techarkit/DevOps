## 🛠️ 1. Create GitHub Environments

### Go to:
1. **Repo → Settings → Environments**
2. Create three environments:
   - `development`
   - `staging`
   - `production`

### Optional (but recommended):
- Add **deployment protection rules** (e.g., required reviewers for `production`).
- Add **environment-specific secrets** (like `PROD_API_KEY`, `STAGING_API_KEY`, etc.).

---

## 🧱 2. Structure Your GitHub Actions Workflow

We’ll create a single workflow file that uses different environments based on the branch.

> 🔁 Branch-to-environment mapping:
- `feature/*` → `development`
- `main` → `staging`
- `release` → `production`

### Example: `.github/workflows/deploy.yml`

```yaml
name: Deploy Pipeline

on:
  push:
    branches:
      - 'main'
      - 'release'
      - 'feature/**'

jobs:
  deploy:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        include:
          - branch: 'feature'
            env_name: development
          - branch: 'main'
            env_name: staging
          - branch: 'release'
            env_name: production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set deployment environment
        id: set-env
        run: |
          echo "GIT_BRANCH=${GITHUB_REF##*/}" >> $GITHUB_ENV
          if [[ "${GITHUB_REF##*/}" == release ]]; then
            echo "DEPLOY_ENV=production" >> $GITHUB_ENV
          elif [[ "${GITHUB_REF##*/}" == main ]]; then
            echo "DEPLOY_ENV=staging" >> $GITHUB_ENV
          else
            echo "DEPLOY_ENV=development" >> $GITHUB_ENV
          fi

  deploy-to-env:
    needs: deploy
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}

    steps:
      - name: Dummy Deploy
        run: echo "Deploying to ${{ env.DEPLOY_ENV }} environment"

      - name: Use environment secret
        run: echo "Using secret"
        env:
          API_KEY: ${{ secrets.API_KEY }}
```

---

## 🧪 3. Add Secrets to Each Environment

In **Repo → Settings → Environments**, add a secret named `API_KEY` to each environment:

- `development` → fake dev key
- `staging` → staging key
- `production` → real production key

Each environment can now **securely use different secrets**.

---

## ✅ 4. Approvals & Rules (Optional)

For `production`, consider:
- **Required reviewers** (e.g., team leads)
- **Wait timer** (delay deployments for observation)
- **Branch protection** to avoid accidental merges

---

## 🔍 5. How This Works in Practice

| Branch pushed to | GitHub Environment used | PR UI shows env? | Needs approval? |
|------------------|-------------------------|------------------|------------------|
| `feature/foo`     | `development`            | ✅               | ❌                |
| `main`            | `staging`                | ✅               | ❌                |
| `release`         | `production`             | ✅               | ✅ if configured  |

---

## 💬 Pro Tips

- You can split `deploy-to-dev`, `deploy-to-staging`, and `deploy-to-prod` into **separate jobs** if you prefer explicit workflows.
- Use `if:` conditions to run environment-specific logic.
- Name your environments **exactly** as in the workflow — they're case-sensitive.

---

Want me to help modularize this workflow or integrate Ansible/Infra code for actual deployment steps?
