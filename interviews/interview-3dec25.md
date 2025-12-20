**Q1: How to secure IaC in CI/CD pipeline**

Securing Infrastructure-as-Code (IaC) in pipelines involves multiple layers:

1. **Secrets Management**

   * Never hardcode credentials/API keys in IaC files.
   * Use tools like **HashiCorp Vault**, **AWS Secrets Manager**, **Azure Key Vault**, or **GitHub Actions secrets**.
   * Example: In Terraform, use `vault_generic_secret` or environment variables.

2. **Static Code Analysis**

   * Scan IaC templates for misconfigurations before deployment.
   * Tools: **Checkov**, **TFSec**, **Terraform Validate**, **SonarQube**.

3. **Policy Enforcement**

   * Implement **policy-as-code** using **OPA (Open Policy Agent)** or **Sentinel**.
   * Example: Ensure no public S3 buckets or open security groups.

4. **Least Privilege**

   * CI/CD service accounts should have only the permissions required to deploy resources.

5. **Immutable Environments & Versioning**

   * Tag and version IaC scripts.
   * Use **immutable deployments** to prevent drift.

6. **Logging & Monitoring**

   * Enable audit logs for deployments (CloudTrail, Azure Activity Logs).

**Memorization trick:** *“Secrets, Scan, Policies, Privilege, Version, Log” → SSPPVL*

---

**Q2: Database of 10TB taking 5 hours for backup – solution**

The goal is to reduce backup time and impact on production:

1. **Incremental or Differential Backups**

   * Instead of full backups every time, only backup changes.

2. **Snapshot-based Backups**

   * Cloud: AWS **EBS snapshots**, Azure **Managed Disk snapshots**, faster and storage-efficient.
   * On-prem: Storage-level snapshots.

3. **Parallelized/Distributed Backups**

   * Split database into chunks and backup concurrently.

4. **Compression & Deduplication**

   * Reduce data size and transfer time.

5. **Backup Scheduling & Retention**

   * Offload to off-peak hours and retain only necessary history.

---

**Q3: On-prem and cloud VNET overlapping – how to connect**

If IP ranges overlap, direct VPN or VNet peering won’t work because routing gets confused. Solutions:

1. **NAT (Network Address Translation)**

   * Translate one side’s IPs to a non-overlapping range.
   * Azure example: **VNet-to-on-prem via VPN with NAT rules**

2. **Re-IP / Subnet Remapping**

   * If feasible, change either on-prem or cloud VNet to non-overlapping IPs.

3. **Proxy / Jump Hosts**

   * Use a bastion/proxy VM to route traffic safely.

---

**Q4: Code 137 in pipeline fail**

* **Exit code 137** usually means: **Container or process was killed due to out-of-memory (OOM)**.
* Common in Docker-based pipelines or CI jobs:

  * The container exceeded memory limits.
  * Kubernetes pod OOMKilled.

**Solution:**

* Increase memory allocation in CI/CD or container.
* Optimize process/memory usage.
* Check logs for memory spikes.

---

