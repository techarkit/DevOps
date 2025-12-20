## 🔹 Azure DevOps Environments in YAML Pipelines – Key Points

1. **Definition Scope**

   * `environment` can be defined only at the **job** or **deployment job** level.
   * It cannot be set globally at the **pipeline** or **stage** level.

2. **Normal Job vs Deployment Job**

   * A **normal job** with `environment:` just tags the job to an environment.
   * A **deployment job** with `environment:` enables approvals, checks, gates, and history tracking in Azure DevOps Environments.

3. **Basic Job Syntax**

   ```yaml
   jobs:
   - job: DeployToDev
     environment: 'Dev'
     steps:
       - script: echo "Deploying to Dev"
   ```

4. **Deployment Job Syntax**

   ```yaml
   jobs:
   - deployment: DeployToProd
     displayName: Deploy to Production
     environment: 'Prod'
     strategy:
       runOnce:
         deploy:
           steps:
             - script: echo "Deploying to Prod"
   ```

5. **Multiple Environments in One Pipeline**

   * A single pipeline can contain multiple jobs targeting different environments (e.g., Dev, QA, Prod).

6. **Environment Naming**

   * Names are case-sensitive.
   * They must match the environment name configured in **Pipelines > Environments**.

7. **Stage Organization**

   * Environments are not defined at the stage level, but you can group jobs by stage (e.g., “Deploy\_Dev” stage and “Deploy\_Prod” stage).

8. **Approvals & Checks**

   * Environments can have **approvals, branch filters, or business hours** configured in Azure DevOps.
   * These policies automatically apply when a deployment job targets that environment.

9. **Security & Access**

   * RBAC (role-based access control) can be applied per environment.
   * You can restrict who can deploy to “Prod” vs. “Dev”.

10. **Resource Checks**

    * You can attach resources (like Kubernetes clusters, VMs, Azure resources) to environments.
    * Checks (like health probes) run before jobs proceed.

11. **History & Audit**

    * Deployment jobs targeting environments log all activity under **Pipelines → Environments → \[EnvironmentName]**.
    * You get a full history of deployments, approvals, and outcomes.

12. **Conditions and Branch Filters**

    * You can use `condition:` on jobs to control if an environment gets deployed to (e.g., only deploy to Prod from `main` branch).

13. **Dependencies**

    * Jobs targeting different environments can be chained using `dependsOn`.
    * Example: Deploy to QA must finish before Deploy to Prod starts.

14. **Approvals are Environment-Level, Not Pipeline-Level**

    * If you set an approval check on “Prod”, *any* job targeting Prod will require that approval.

15. **Automatic Environment Creation**

    * If you reference an environment name that doesn’t exist, Azure DevOps automatically creates it the first time the pipeline runs.

16. **Same Environment Across Multiple Pipelines**

    * Multiple pipelines can target the same environment.
    * Approvals/checks still apply consistently across them.

17. **Environment Resources**

    * You can attach resources to environments:

      * Virtual machines
      * Kubernetes clusters
      * Azure resources
      * Generic resources

18. **Manual Intervention**

    * Approvals configured in environments force a manual step before the deployment proceeds.

19. **Runtime Variables**

    * You can reference environment variables from within jobs, but `environment:` keyword itself does not accept pipeline variables.
    * You must use static environment names or templates for dynamic usage.

20. **Best Practice**

    * Use **deployment jobs** for real deployments (Prod, QA).
    * Use **normal jobs** with `environment:` only for tagging/logical grouping.

---
