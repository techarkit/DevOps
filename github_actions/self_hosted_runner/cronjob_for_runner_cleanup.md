If you're looking to set up a **cron job** specifically for cleaning up the **GitHub Actions runner workspace** on your **self-hosted runner**, here's a detailed breakdown of how to automate the cleanup process using cron.

### Step-by-Step Cron Job Setup for Cleanup

You want to clean up the `_work` directory where GitHub stores repositories for the runner after each job. Below is an example of how to configure a **cron job** for periodic cleanup, typically done on a weekly basis to avoid accumulating unnecessary files.

---

### 🧑‍💻 Cron Job Setup

1. **Create a Cleanup Script:**
   Create a script that removes old data from the runner’s `_work` directory. This script will be executed by the cron job.

   ```bash
   sudo nano /home/github-runner/actions-runner/.github/hooks/cleanup.sh
   ```

   Inside the `cleanup.sh` script, add the following:

   ```bash
   #!/bin/bash
   # Cleanup GitHub Actions runner workspace
   echo "Cleaning up GitHub Actions runner workspace..."
   rm -rf /home/github-runner/actions-runner/_work/*
   ```

   Make sure the script is executable:

   ```bash
   sudo chmod +x /home/github-runner/actions-runner/.github/hooks/cleanup.sh
   ```

---

2. **Set Up Cron Job:**
   Now you need to schedule the cron job that will execute the `cleanup.sh` script periodically.

   - Run `crontab -e` to open the cron editor for the `github-runner` user:

   ```bash
   sudo crontab -e -u github-runner
   ```

   - Add the following cron job to run the cleanup script weekly (on Sundays at 3 AM):

   ```bash
   0 3 * * 0 /home/github-runner/actions-runner/.github/hooks/cleanup.sh > /home/github-runner/actions-runner/.github/hooks/cleanup.log 2>&1
   ```

   ### Breakdown of the cron schedule:
   - `0 3 * * 0`: This runs the job at 3:00 AM every Sunday.
   - `/home/github-runner/actions-runner/.github/hooks/cleanup.sh`: Path to the cleanup script.
   - `> /home/github-runner/actions-runner/.github/hooks/cleanup.log 2>&1`: Redirects the output and errors to a log file for troubleshooting.

---

3. **Ensure Cron is Running:**
   To make sure that cron is running and executing jobs properly, you can check the status of cron by running:

   ```bash
   sudo systemctl status cron
   ```

   If the service isn't running, start it with:

   ```bash
   sudo systemctl start cron
   ```

   And to enable cron to start automatically on boot:

   ```bash
   sudo systemctl enable cron
   ```

---

### ✅ Verifying Cleanup:

- After the cron job runs, you can check if the cleanup process works by inspecting the `_work` directory:

  ```bash
  ls /home/github-runner/actions-runner/_work/
  ```

- If there are old files, they should be removed after the scheduled time.

---

### 💡 Additional Customization:

1. **Change the Frequency**: You can adjust the cron job timing by modifying the cron schedule. For example:
   - **Daily Cleanup**: `0 3 * * *` (every day at 3 AM)
   - **Monthly Cleanup**: `0 3 1 * *` (every first day of the month)

2. **Logging**: You can set up a more detailed logging mechanism by directing output to a specific log file like:
   ```bash
   > /home/github-runner/actions-runner/cleanup.log 2>&1
   ```

   This will help you review what was cleaned or if there were any issues during the cleanup process.

---

This is a simple yet effective way to keep your GitHub Actions self-hosted runner from accumulating unnecessary files in the workspace.
