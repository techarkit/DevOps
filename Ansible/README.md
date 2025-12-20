# 📘 Ansible Automation Repository

## Readword Demo:

- https://github.com/NASTP-ce/llm-arena/tree/main/ansible



This repository contains **infrastructure automation playbooks** and **roles** managed with Ansible.
It follows a best-practice layout where all automation tasks (NFS, Docker, monitoring tools, etc.) live in one place.

---

## Install Ansible and Shell Autocompletion

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html


# Autocomplete:

```bash
#  Install argcomplete globally (easier)
bashsudo apt install python3-argcomplete

# Then use:

basheval "$(register-python-argcomplete3 ansible)"
eval "$(register-python-argcomplete3 ansible-playbook)"
eval "$(register-python-argcomplete3 ansible-vault)"
eval "$(register-python-argcomplete3 ansible-galaxy)"
eval "$(register-python-argcomplete3 ansible-config)"
```


## 📂 Directory Structure

```
ansible-project/
├── inventories/
│   ├── production/
│   │   └── hosts.ini        # Host inventory (server/client groups)
├── roles/
│   ├── nfs_server/          # Role to configure NFS server
│   │   └── tasks/main.yml
│   ├── nfs_client/          # Role to configure NFS clients
│   │   └── tasks/main.yml
│   ├── <future_roles>/      # Add new roles here (e.g., docker, prometheus)
├── playbooks/
│   └── site.yml             # Main entry playbook (calls roles)
└── ansible.cfg              # Global Ansible configuration
```

### 🔹 Key Components

* **inventories/** → Defines hosts and groups (production, staging, etc.)
* **roles/** → Modular automation units (server/client/software configs)
* **playbooks/** → Playbooks that orchestrate roles on host groups
* **ansible.cfg** → Defaults (inventory, SSH options, etc.)

---

## ▶️ Usage

### 1. Check connectivity

```bash
ansible all -m ping
```

### 2. Run main site playbook

```bash
ansible-playbook playbooks/site.yml
```

### 3. Run playbook for a specific host group

```bash
ansible-playbook playbooks/site.yml --limit nfs_clients
```

### 4. Run a single ad-hoc command

```bash
ansible all -a "uptime"
ansible nfs_server -a "df -h"
```

### 5. Run a role/playbook with tags

```bash
ansible-playbook playbooks/site.yml --tags "nfs"
```

---

## 🔧 Adding New Software (Best Practice)

1. Create a new role:

   ```bash
   ansible-galaxy init roles/<new_role_name>
   ```

   Example: `roles/docker/`

2. Add tasks in `roles/<new_role_name>/tasks/main.yml`

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

## 📝 Frequently Used Commands Cheat Sheet

* **Check syntax before running**

  ```bash
  ansible-playbook playbooks/site.yml --syntax-check
  ```

* **Dry run (see changes without applying)**

  ```bash
  ansible-playbook playbooks/site.yml --check
  ```

* **Limit to one host**

  ```bash
  ansible-playbook playbooks/site.yml --limit 192.168.1.12
  ```

* **Run with more output**

  ```bash
  ansible-playbook playbooks/site.yml -vvv
  ```

---

✅ With this structure, all your **future software installations** can be added as new roles.
This makes it easy to scale your automation across multiple environments.

---
