Let’s set up **Git hooks for a Python Flask project** to automate code quality checks, testing, and security scans before commits/pushes. Below are practical examples using **pre-commit** and **pre-push** hooks.

---

### **1. Setup Git Hooks Directory**
First, create a `.githooks` folder in your project root (to version-control hooks):
```bash
mkdir .githooks
cd .githooks
touch pre-commit pre-push
chmod +x pre-commit pre-push  # Make them executable
```

Then configure Git to use this directory:
```bash
git config core.hooksPath .githooks
```

---

### **2. Pre-commit Hook (`pre-commit`)**
This hook will run **before every commit** to:
- Format code with `black`.
- Check for linting errors with `flake8`.
- Check for security issues with `bandit`.

#### **Script (`.githooks/pre-commit`)**:
```bash
#!/bin/bash

# Activate virtualenv (if using one)
source venv/bin/activate  # Adjust path if needed

echo "Running pre-commit checks..."

# 1. Format code with Black
black --check .
if [ $? -ne 0 ]; then
  echo "Black found formatting issues. Run 'black .' to fix."
  exit 1
fi

# 2. Lint with Flake8
flake8 .
if [ $? -ne 0 ]; then
  echo "Flake8 found linting errors!"
  exit 1
fi

# 3. Security scan with Bandit (optional)
bandit -r .
if [ $? -ne 0 ]; then
  echo "Bandit found security issues!"
  exit 1
fi

echo "Pre-commit checks passed! Proceeding with commit."
exit 0
```

#### **Dependencies**:
Install the tools if you haven’t:
```bash
pip install black flake8 bandit
```

---

### **3. Pre-push Hook (`pre-push`)**
This hook runs **before pushing to remote** to:
- Run unit tests with `pytest`.
- Ensure migrations are up-to-date (if using Flask-Migrate).

#### **Script (`.githooks/pre-push`)**:
```bash
#!/bin/bash

# Activate virtualenv
source venv/bin/activate

echo "Running pre-push checks..."

# 1. Run pytest
pytest tests/ -v
if [ $? -ne 0 ]; then
  echo "Tests failed! Fix before pushing."
  exit 1
fi

# 2. Check for unapplied migrations (if using Flask-Migrate)
flask db check 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Database migrations pending! Run 'flask db upgrade'."
  exit 1
fi

echo "All checks passed. Pushing to remote..."
exit 0
```

#### **Dependencies**:
```bash
pip install pytest Flask-Migrate
```

---

### **4. Optional: Use `pre-commit` Framework**
For a more maintainable approach, use the [`pre-commit`](https://pre-commit.com/) framework:

1. Install:
   ```bash
   pip install pre-commit
   ```

2. Create `.pre-commit-config.yaml`:
   ```yaml
   repos:
     - repo: https://github.com/psf/black
       rev: 23.12.0
       hooks:
         - id: black
     - repo: https://github.com/PyCQA/flake8
       rev: 6.1.0
       hooks:
         - id: flake8
   ```

3. Install hooks:
   ```bash
   pre-commit install
   ```

---

### **5. Testing the Hooks**
1. Try committing with linting errors:
   ```bash
   git commit -m "Test commit"
   ```
   - If `black`/`flake8` fail, the commit is blocked.

2. Try pushing with failing tests:
   ```bash
   git push origin main
   ```
   - If `pytest` fails, the push is blocked.

---

### **Key Checks for Flask Projects**
| Hook         | Tool       | Purpose                          |
|--------------|------------|----------------------------------|
| `pre-commit` | `black`    | Auto-format Python code          |
| `pre-commit` | `flake8`   | Enforce PEP8 style               |
| `pre-commit` | `bandit`   | Security vulnerability scanning  |
| `pre-push`   | `pytest`   | Run unit tests                   |
| `pre-push`   | `flask db` | Check pending migrations         |

---

### **Troubleshooting**
- **Hook not running?** Ensure it’s executable:
  ```bash
  chmod +x .githooks/pre-commit
  ```
- **Bypass hooks** (if absolutely needed):
  ```bash
  git commit --no-verify
  ```

---

### **Final Notes**
- Store hooks in `.githooks/` and share them with the team.
- Combine with **CI/CD** (e.g., GitHub Actions) for double-checking.
- For larger teams, consider **server-side hooks** (e.g., in GitHub/GitLab).
