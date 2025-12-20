Sure! Below is an **Ansible playbook** that will help you automate the setup of a **GitHub Actions self-hosted runner** along with periodic cleanup of the workspace.

This playbook will:
1. Install the GitHub Actions self-hosted runner.
2. Set up the runner as a service.
3. Configure a **cron job** for periodic cleanup of the workspace (e.g., weekly).

### 🧑‍💻 **Ansible Playbook** for GitHub Actions Self-Hosted Runner Setup + Periodic Cleanup

```yaml
---
- name: Setup GitHub Actions Self-Hosted Runner with Periodic Cleanup
  hosts: all
  become: yes
  tasks:
    - name: Install required packages for runner
      apt:
        name:
          - curl
          - jq
          - wget
        state: present
        update_cache: yes

    - name: Create directory for GitHub Actions runner
      file:
        path: "/home/github-runner/actions-runner"
        state: directory
        owner: github-runner
        group: github-runner
        mode: '0755'

    - name: Download the latest GitHub Actions runner
      shell: |
        cd /home/github-runner/actions-runner
        curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.0/actions-runner-linux-x64-2.300.0.tar.gz
        tar xzf actions-runner.tar.gz
      args:
        creates: "/home/github-runner/actions-runner/config.sh"

    - name: Create user for GitHub runner (if not already exists)
      user:
        name: github-runner
        comment: GitHub Actions Runner
        home: /home/github-runner
        shell: /bin/bash
        state: present

    - name: Configure GitHub runner
      shell: |
        cd /home/github-runner/actions-runner
        ./config.sh --url https://github.com/<YOUR_ORG>/<YOUR_REPO> --token {{ runner_token }}
      environment:
        RUNNER_ALLOW_RUNASROOT: "1"
      args:
        creates: "/home/github-runner/actions-runner/.runner"

    - name: Install GitHub runner as a systemd service
      shell: |
        cd /home/github-runner/actions-runner
        sudo ./svc.sh install github-runner
        sudo ./svc.sh start github-runner
      args:
        creates: "/etc/systemd/system/github-runner.service"

    - name: Set up periodic cleanup cron job
      cron:
        name: "Cleanup GitHub Actions Runner Workspace"
        minute: "0"
        hour: "3"
        day: "0"
        job: "/home/github-runner/actions-runner/.github/hooks/post-job.sh"
        state: present
        user: github-runner

    - name: Create post-job cleanup script
      copy:
        dest: "/home/github-runner/actions-runner/.github/hooks/post-job.sh"
        content: |
          #!/bin/bash
          echo "Cleaning up GitHub Actions runner workspace..."
          rm -rf /home/github-runner/actions-runner/_work/*

      mode: '0755'
      owner: github-runner
      group: github-runner

    - name: Ensure cleanup script is executable
      file:
        path: "/home/github-runner/actions-runner/.github/hooks/post-job.sh"
        mode: '0755'
        owner: github-runner
        group: github-runner
```

---

### Explanation of the Playbook:

1. **Install Required Packages:**
   - This installs `curl`, `jq`, and `wget` to download and set up the GitHub Actions runner.

2. **Download GitHub Actions Runner:**
   - Downloads the latest version of the GitHub Actions runner package.
   - Extracts the package to `/home/github-runner/actions-runner`.

3. **Create User for GitHub Runner:**
   - If the `github-runner` user doesn't exist, it will be created with the specified home directory.

4. **Configure GitHub Runner:**
   - This step configures the runner with your GitHub organization/repository using a runner token.
   - You'll need to pass the `runner_token` as a variable or store it securely in a Vault/secret management solution.

5. **Install GitHub Runner as a Systemd Service:**
   - The runner is installed as a systemd service, and it will be automatically started.

6. **Set Up Periodic Cleanup:**
   - A **cron job** is scheduled to run weekly (on Sundays at 3 AM) to invoke the `post-job.sh` cleanup script.
   - This script will delete any old workspace files to prevent the runner directory from accumulating unnecessary data.

7. **Post-Job Cleanup Script:**
   - The script `/home/github-runner/actions-runner/.github/hooks/post-job.sh` will be created to handle the cleanup of the `_work` directory after each job is completed. It will clear the directory to keep the runner environment clean.

---

### 💡 Customization:

- **Runner Token**: You’ll need to set up a **GitHub personal access token** (or use GitHub's authentication) for the runner during the configuration step. This should be securely passed into the playbook via variables or secrets.
  
- **Cron Frequency**: The cron job is set to clean up weekly (`minute: "0"`, `hour: "3"`, `day: "0"`). Adjust the timing if needed (e.g., daily, monthly).

- **GitHub URL**: Replace `<YOUR_ORG>/<YOUR_REPO>` with your specific repository or organization URL.

---

### How to Run the Playbook:

1. Save this playbook to a file, e.g., `setup_github_runner.yml`.
2. Run the playbook with Ansible:
   ```bash
   ansible-playbook setup_github_runner.yml -e "runner_token=YOUR_RUNNER_TOKEN"
   ```

   Replace `YOUR_RUNNER_TOKEN` with the actual GitHub runner token you generated in your repository settings.

---

Let me know if you need any adjustments or more information about customizing this for your environment!
