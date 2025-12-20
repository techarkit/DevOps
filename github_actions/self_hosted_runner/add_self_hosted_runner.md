Awesome! Here's a **detailed, step-by-step guide** to set up a **secure, production-ready GitHub self-hosted runner on Linux** using a **dedicated non-root user**.

---

## 🛡️ Secure GitHub Actions Self-Hosted Runner on Linux

### ✅ Overview

This guide covers:

- Creating a dedicated non-root user (`github-runner`)
- Downloading and configuring the GitHub runner
- Installing it as a service
- Granting limited `sudo` access (if needed)
- Tips for hardening and maintenance

---

### 🧰 Prerequisites

- Ubuntu/Debian Linux system (or any systemd-based Linux)
- `curl`, `tar`, and basic tools installed
- GitHub repo or org where you want to add the runner

---

## 🔧 Step-by-Step Setup

---

### 1. 👤 Create a dedicated runner user

```bash
sudo useradd -m -s /bin/bash github-runner
```

Set a password if needed (e.g., for debugging or SSH access):

```bash
sudo passwd github-runner
```

---

### 2. 🔐 Log in as the runner user

```bash
sudo su - github-runner
```

---

### 3. 📦 Download the GitHub runner package

Visit: [https://github.com/actions/runner/releases](https://github.com/actions/runner/releases)

Find the latest version for Linux.

Then run:

```bash
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -O -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.323.0.tar.gz
```

---

### 4. 🔗 Configure the runner

On GitHub:

- Go to your repo → Settings → Actions → Runners → Add Runner
- Select **Linux** → **x64** → Follow instructions to get the token and URL.

Run the command they provide, e.g.:

```bash
./config.sh --url https://github.com/your-org/your-repo --token <TOKEN>
```

It will prompt for:
- Name (default is fine)
- Work folder (default is `_work`)
- Labels (optional)

---

### 5. 🛠️ Install and start as a systemd service

Back in your `actions-runner` directory:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Check status:

```bash
sudo ./svc.sh status
```

Logs can be found in:
```bash
~/actions-runner/_diag/
```

---

## 🚀 Optional: Granting Limited `sudo` Access

If your workflows need root-level actions (e.g., restart services), give limited `sudo` rights:

```bash
sudo visudo -f /etc/sudoers.d/github-runner
```

Example:
```bash
github-runner ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
```

✅ This allows only restarting Nginx, no full `sudo` rights.

---

## 🛡️ Hardening Tips

- Only allow access to the runner box from trusted IPs (firewall).
- Disable SSH login for the runner user (optional):
  ```bash
  sudo usermod -s /usr/sbin/nologin github-runner
  ```
- Limit sudo as shown above.
- Use runner groups and labels in GitHub to scope runners to trusted repositories only.

---

## 🧼 Uninstall / Reconfigure

To remove:

```bash
sudo ./svc.sh stop
sudo ./svc.sh uninstall
./config.sh remove
```

To reconfigure (after `remove`):

```bash
./config.sh --url <your-url> --token <new-token>
```

---

## 📜 Example Ansible Snippet (if desired)

Let me know if you'd like an `ansible.builtin.user`, `ansible.builtin.get_url`, and `ansible.builtin.command`-based Ansible playbook for automating all this.

---

Would you like me to turn this into a markdown doc or uploadable file too?
