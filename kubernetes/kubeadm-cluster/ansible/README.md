# 📘 Ansible Automation Repository — Disable Swap Example

This repository contains **infrastructure automation playbooks** and **roles** managed with Ansible.
It follows a **best-practice layout** where all automation tasks (disable swap, NFS, Docker, monitoring tools, etc.) live in one place.

---

## 1. Install Ansible and Shell Autocompletion

👉 Official docs:
[https://docs.ansible.com/ansible/latest/installation\_guide/intro\_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

```bash
# Install ansible (Ubuntu)
sudo apt update && sudo apt install ansible -y

# Enable bash completion (optional)
sudo apt install bash-completion -y
echo 'eval "$(register-python-argcomplete ansible)"' >> ~/.bashrc
```

---

## 2. 📂 Directory Structure (Complete Example)

```
ansible-project/
├── ansible.cfg              # Global Ansible configuration
├── inventories/
│   ├── production/
│   │   └── hosts.ini        # Host inventory (server/client groups)
│   ├── staging/
│   │   └── hosts.ini
├── playbooks/
│   ├── site.yml             # Main entry playbook (calls roles)
│   ├── disable-swap.yml     # Playbook to disable swap
│   └── enable-swap.yml      # Rollback playbook to re-enable swap
├── roles/
│   ├── disable_swap/        # Role to disable swap
│   │   ├── tasks/main.yml
│   │   ├── defaults/main.yml
│   │   ├── handlers/main.yml
│   │   ├── meta/main.yml
│   │   └── README.md
│   ├── nfs_server/          # Example: configure NFS server
│   │   └── tasks/main.yml
│   ├── nfs_client/          # Example: configure NFS clients
│   │   └── tasks/main.yml
│   └── <future_roles>/      # e.g., docker, prometheus, grafana
├── tests/
│   └── molecule/            # Molecule test scenarios
└── .github/workflows/
    └── ansible-ci.yml       # CI pipeline (lint, test, deploy)
```

---

### 🔹 Key Components

* **inventories/** → Defines hosts and groups (`production`, `staging`, etc.)
* **roles/** → Modular automation units (disable swap, NFS, Docker, monitoring configs)
* **playbooks/** → Orchestrate roles on host groups
* **ansible.cfg** → Defaults (inventory, SSH, forks, etc.)
* **tests/** → Molecule and testinfra for integration testing
* **.github/workflows/** → CI/CD pipelines for lint/test/deploy

---

## 3. ▶️ Usage

### 1. Check connectivity

```bash
ansible all -m ping
```

### 2. Run main site playbook

```bash
ansible-playbook playbooks/site.yml
```

### 3. Run playbook for specific host group

```bash
ansible-playbook playbooks/disable-swap.yml --limit ubuntu_nodes
```

### 4. Run a single ad-hoc command

```bash
ansible all -a "uptime"
ansible ubuntu_nodes -a "df -h"
```

### 5. Run a role/playbook with tags

```bash
ansible-playbook playbooks/site.yml --tags "swap"
```

---

## 4. 🔧 Adding New Software (Best Practice)

1. Create a new role:

   ```bash
   ansible-galaxy init roles/docker
   ```

2. Add tasks in:

   ```
   roles/docker/tasks/main.yml
   ```

3. Include the role in `playbooks/site.yml`:

   ```yaml
   - name: Install Docker
     hosts: all
     become: yes
     roles:
       - docker
   ```

4. Run:

   ```bash
   ansible-playbook playbooks/site.yml
   ```

---

## 5. 📝 Frequently Used Commands Cheat Sheet

* **Check syntax before running**

  ```bash
  ansible-playbook playbooks/disable-swap.yml --syntax-check
  ```

* **Dry run (see changes without applying)**

  ```bash
  ansible-playbook playbooks/disable-swap.yml --check --diff
  ```

* **Limit to one host**

  ```bash
  ansible-playbook playbooks/disable-swap.yml --limit node1
  ```

* **Run with more output**

  ```bash
  ansible-playbook playbooks/disable-swap.yml -vvv
  ```

---

## 6. 🚀 CI/CD Integration

GitHub Actions example (`.github/workflows/ansible-ci.yml`):

```yaml
name: Ansible CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y python3-pip
          pip install ansible ansible-lint yamllint molecule[docker]

      - name: Run yamllint
        run: yamllint .

      - name: Run ansible-lint
        run: ansible-lint -v

      - name: Run molecule tests
        run: molecule test
```

---

## 7. ✅ Benefits

* **Standardized repo structure** (easy onboarding and scaling)
* **Modular roles** (disable swap, NFS, Docker, Prometheus, etc.)
* **CI/CD pipeline** ensures code quality and test automation
* **Safe rollback** playbooks (re-enable swap if needed)
* **Future-proof** → easily extendable with new roles

---


