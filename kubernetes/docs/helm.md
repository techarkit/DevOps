### What is Helm?

**Helm** is a package manager for Kubernetes, designed to simplify the process of deploying and managing applications on Kubernetes clusters. Helm uses a packaging format called **charts**, which are collections of files that describe a related set of Kubernetes resources. Helm helps you to:
- **Install** applications (via charts) on Kubernetes.
- **Upgrade** applications with new versions.
- **Manage** application dependencies.
- **Rollback** to previous versions of your applications.
  
In essence, Helm allows you to easily define, install, and upgrade even the most complex Kubernetes applications using a single command.

---

### How to Install Helm on Ubuntu

Follow these steps to install Helm on an Ubuntu system:

####  **Install Helm using Script**
Helm provides a simple installation script to automate the process:

```bash
# Download the Helm installation script
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

This script downloads and installs the latest version of Helm (Helm 3). After installation, you can verify the installation by running:

```bash
helm version
```

#### **Install Helm via APT (Package Manager)**

Alternatively, you can install Helm using the package manager by adding the Helm repository:

```bash
# Add the Helm GPG key and repository
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Update the package list
sudo apt-get update

# Install Helm
sudo apt-get install helm
```

Verify the installation:

```bash
helm version
```

### **Show Available Commands**
   To see all available Helm commands:
   ```bash
   helm help
   ```

---

### How to Use Helm

Once Helm is installed, you can start using it to manage Kubernetes applications via Helm **charts**.

####  **Initialize Helm**
In Helm 3 (the latest version), Helm no longer requires a separate server-side component (`tiller`), so there's no need to initialize Helm. You can directly start using Helm commands.

####  **Searching for a Helm Chart**
Helm allows you to search for charts available in public repositories (like the Helm stable repository).

```bash
# Search for a chart (e.g., for MySQL)
helm search repo mysql
```
Initially, there would be no repository.

####  **Adding a Helm Repository**
Helm repositories are where charts are stored. You can add public repositories like `bitnami` for application charts.

```bash
# Add the Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update the Helm repository to fetch the latest charts
helm repo update
```

Here are the main Helm repositories you can add:

 **Bitnami**: Popular open-source applications.
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   ```

 **Elastic**: ELK stack (Elasticsearch, Kibana, Logstash).
   ```bash
   helm repo add elastic https://helm.elastic.co
   ```

 **Ingress NGINX**: NGINX Ingress Controller.
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   ```

 **Jetstack**: Cert-Manager (SSL certificates).
   ```bash
   helm repo add jetstack https://charts.jetstack.io
   ```

 **Prometheus Community**: Prometheus & monitoring tools.
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   ```

 **Grafana**: Grafana, Loki, observability tools.
   ```bash
   helm repo add grafana https://grafana.github.io/helm-charts
   ```

 **Artifact Hub**: Centralized hub for various Helm charts.
   - **URL**: https://artifacthub.io

These are the most popular and widely used repositories for Kubernetes applications.

###  **List Helm Repositories**
   To see the list of repositories you’ve added to Helm:
   ```bash
   helm repo list
   ```

###  **Update Helm Repositories**
   Update all the repositories to get the latest chart information:
   ```bash
   helm repo update
   ```

###  **Search Charts in a Repository**
   To search for charts in the repositories you've added:
   ```bash
   helm search repo <chart_name>
   ```
   Example:
   ```bash
   helm search repo nginx
   ```

#### **Installing a Helm Chart**
After adding the repository, you can install a chart. For example, installing **MySQL** from the Bitnami repository:

```bash
# Install MySQL with Helm
helm install my-mysql bitnami/mysql
```

- `my-mysql` is the release name for your deployment.
- `bitnami/mysql` is the chart name.

This will install the MySQL application in your Kubernetes cluster.

#### **Listing Installed Helm Releases**
To view all Helm releases (applications) installed on your Kubernetes cluster:

```bash
helm list
```

#### **Upgrading a Helm Release**
You can upgrade an application by upgrading the corresponding Helm chart.

```bash
helm upgrade my-mysql bitnami/mysql
```

#### **Uninstalling a Helm Release**
To remove an application from your Kubernetes cluster:

```bash
helm uninstall my-mysql
```

#### **Viewing Helm Chart Values**
Helm charts often have configurable options. You can inspect the available values for a chart by using the following command:

```bash
helm show values bitnami/mysql
```

#### **Customizing a Helm Install**
You can override the default values provided in the chart using the `--set` flag:

```bash
helm install my-mysql bitnami/mysql --set mysqlRootPassword=secretpassword,mysqlUser=myuser
```

Alternatively, you can create a YAML file with the custom values and use that during installation:

```bash
# Create a custom-values.yaml file
vim custom-values.yaml

# Use the custom-values.yaml during installation
helm install my-mysql bitnami/mysql -f custom-values.yaml
```

---

### Basic Helm Commands Summary

- **Add a repository**: `helm repo add <repo-name> <repo-url>`
- **Search for charts**: `helm search repo <chart-name>`
- **Install a chart**: `helm install <release-name> <chart-name>`
- **List installed charts**: `helm list`
- **Upgrade a release**: `helm upgrade <release-name> <chart-name>`
- **Uninstall a release**: `helm uninstall <release-name>`

Helm simplifies deploying and managing Kubernetes applications, enabling you to define your application setup as reusable templates.
