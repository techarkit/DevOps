### kubectl Overview

`kubectl` is the main command-line tool used to manage Kubernetes clusters, including both local clusters like Minikube and remote cloud-based clusters. It plays a vital role in interacting with Kubernetes resources such as deployments, services, pods, and more.

#### Key Features of `kubectl`:
- **Cluster Management**: `kubectl` provides full control over Kubernetes clusters by allowing users to manage cluster objects, scale applications, monitor health, and more.
- **Local & Remote**: It works equally well with Minikube (local clusters) and remote Kubernetes clusters hosted on cloud platforms.
- **Configuration Flexibility**: Depending on the setup, `kubectl` may need manual configuration for cluster access, or it may receive configuration details automatically in environments like Minikube.

#### Using kubectl with Minikube
Minikube comes with its own version of `kubectl`, bundled within the Minikube CLI. However, this is not the preferred method since the `kubectl` commands become subcommands of the `minikube` command. For example:

```bash
# Using kubectl as a Minikube subcommand
minikube kubectl -- get pods
```

This is inconvenient compared to the standalone usage:

```bash
# Standard kubectl usage
kubectl get pods
```

**Solution**: It is recommended to install `kubectl` as a standalone tool to avoid these long command sequences. Additionally, a standalone installation provides better flexibility, especially when working with multiple Kubernetes clusters.

#### Installing kubectl

There are several methods for installing `kubectl`, and they are documented in the official Kubernetes documentation. Some of the common installation methods include:

1. **Using Package Managers**: 
   - For Linux systems, `kubectl` can be installed using package managers like `apt` or `yum`.
   - On macOS, it can be installed using Homebrew.
   - For Windows, `kubectl` can be installed via `chocolatey` or `scoop`.

2. **Manual Installation**:
   - Download the latest version of `kubectl` directly from the Kubernetes GitHub releases and place it in a directory within your system's `$PATH`.

3. **Minikube-Bundled**:
   - While less recommended, users can utilize the `kubectl` bundled with Minikube if a standalone installation is not required.

To install `kubectl` on a Linux system, you can follow the steps outlined below. This process involves downloading the latest stable version of the `kubectl` binary and setting it up for use.

#### Step-by-Step Installation

1. **Download the Latest Stable Binary**:
   You can use `curl` to download the latest stable version of `kubectl` directly from the Kubernetes release server. Run the following command in your terminal:

   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   ```

   This command fetches the latest stable release version of `kubectl` for Linux.

2. **Install the Binary**:
   Once the binary is downloaded, install it with the following command to place it in the `/usr/local/bin/` directory, making it accessible system-wide:

   ```bash
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

3. **Verify the Installation**:
   After installation, you can verify that `kubectl` has been installed successfully by checking its version:

   ```bash
   kubectl version --client
   ```

   This command should display the version information for the `kubectl` client.

#### Installing a Specific Version

If you need to install a specific version of `kubectl` (for example, v1.28.3), which may be necessary to align with the version of your Minikube cluster, you can use the following command:

```bash
curl -LO https://dl.k8s.io/release/v1.28.3/bin/linux/amd64/kubectl
```

After downloading the specific version, you would follow the same installation command as before to place it in the correct directory.

#### Enabling Shell Autocompletion

To enhance the usability of `kubectl`, you can enable shell autocompletion. This feature allows you to complete `kubectl` commands and options by pressing the TAB key in your terminal.

1. **Install Bash Completion**:
   First, ensure that `bash-completion` is installed. You can do this by updating your package list and installing it with:

   ```bash
   sudo apt update && sudo apt install -y bash-completion
   ```

2. **Configure Autocompletion**:
   After installing `bash-completion`, set it up by running the following commands:

   ```bash
   source /usr/share/bash-completion/bash_completion
   source <(kubectl completion bash)
   ```

3. **Persist Autocompletion in Your Shell**:
   To make this configuration persistent across terminal sessions, add the following line to your `~/.bashrc` file:

   ```bash
   echo 'source <(kubectl completion bash)' >> ~/.bashrc
   ```

   Then, refresh your shell session with:

   ```bash
   source ~/.bashrc
   ```

Now, you should have `kubectl` installed and configured with autocompletion enabled, making it easier to manage your Kubernetes clusters efficiently.

### kubectl Configuration File

The `kubectl` client interacts with a Kubernetes cluster by accessing the API Server, which requires specific connection details and authentication credentials. When starting Minikube, a configuration file named `config` is created by default inside the `.kube` directory in the user's home directory. This file, commonly referred to as the kubeconfig, contains all necessary connection information for `kubectl` to communicate with the Kubernetes API Server.

#### Key Components of the kubeconfig File

- **Control Plane Node Endpoint**: This specifies the server address where the API Server is running. It is represented in the format:  
  ```
  server: https://192.168.99.100:8443
  ```

- **Authentication Credentials**: The kubeconfig file includes paths to the client authentication key and certificate. These credentials enable secure access to the API Server.

- **Cluster Details**: This section outlines the cluster's name and its configuration. Each cluster entry specifies connection parameters like certificate authority and server endpoint.

- **Contexts**: Contexts define the cluster and user combinations for easier switching between different Kubernetes environments.

- **Users**: This section contains user authentication details, including client certificates and keys.

#### Viewing the kubeconfig File

You can view the contents of the kubeconfig file to examine the connection details using the following command:

```bash
kubectl config view
```

This command outputs details like the API Server's endpoint, user credentials, and cluster settings. A sample output might look like this:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/student/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/student/.minikube/profiles/minikube/client.crt
    client-key: /home/student/.minikube/profiles/minikube/client.key
```

In this example:
- The **`server`** entry indicates the API Server's address.
- **`client-certificate`** and **`client-key`** point to the credentials used for authentication.

#### Cluster Information

Once `kubectl` is installed and configured, you can display information about your Minikube Kubernetes cluster using the command:

```bash
kubectl cluster-info
```

The expected output might be:

```
Kubernetes master is running at https://192.168.99.100:8443
KubeDNS is running at https://192.168.99.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

For debugging and diagnosing cluster problems, you can use:

```bash
kubectl cluster-info dump
```

#### Manual Configuration for Other Tools

While Minikube automatically creates the kubeconfig file in `~/.kube/config`, other Kubernetes installation methods may require you to create and configure this file manually. This involves setting up the necessary cluster access points, authentication mechanisms, and network configurations specific to your environment.

#### Versioning Considerations
It is recommended to keep `kubectl` within **one minor version** of the Kubernetes cluster's version to ensure compatibility. Mismatched versions may result in unpredictable behavior or limited access to features.

#### Configuration of kubectl

After installation, `kubectl` needs to be configured to access the desired Kubernetes cluster. For Minikube, this configuration is automatic, but for other Kubernetes clusters, users may need to:

- Specify the **API server's** endpoint.
- Set up **authentication credentials** (certificates, tokens, etc.).
- Configure the **Kubeconfig** file, which holds cluster details for `kubectl`.

**Example Command**:
```bash
# Configure kubectl to use a different Kubernetes cluster
kubectl config set-cluster my-cluster --server=https://<api-server-endpoint>
```


#### 2. **Set Up `kubectl`**
Minikube automatically configures `kubectl` to work with your local Kubernetes cluster. Verify that `kubectl` is connected to Minikube:
```bash
kubectl cluster-info
```

This will show details about the Kubernetes cluster and confirm that `kubectl` is configured correctly. like:
```
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
- The **control plane** is responsible for managing the Kubernetes cluster and is accessible via the API server.
- **CoreDNS** provides DNS resolution for services in the cluster, allowing pods to communicate using service names instead of IP addresses. It's running within the kube-system namespace and accessible via a proxy URL.


### CRUD Operations at the Deployment Level

In Kubernetes, CRUD (Create, Read, Update, Delete) operations primarily occur at the **Deployment** level. A **Deployment** defines the desired state for your application, such as the number of replicas and the container images used.

- **Create**: A deployment is created using YAML or a CLI command (`kubectl apply -f deployment.yaml`), defining the pods and containers Kubernetes should manage.
- **Read**: You can inspect the status of a deployment using `kubectl get deployments` or `kubectl describe deployment`.
- **Update**: Updates to a deployment, like changing container images or scaling replicas, are handled with `kubectl apply` or `kubectl set image`, and Kubernetes automatically applies the changes to the underlying resources (like Pods).
- **Delete**: When a deployment is deleted using `kubectl delete`, Kubernetes automatically removes the underlying Pods and resources.

Anything underneath a deployment (such as Pods, Replicasets, etc.) is managed automatically by Kubernetes as specified in the deployment.

### Kubernetes Dashboard

The **Kubernetes Dashboard** is a web-based user interface that facilitates the management of Kubernetes clusters. It provides a visual overview of cluster resources, workloads, and configurations, making it easier to interact with and monitor your applications.

#### Enabling the Dashboard in Minikube

In Minikube, the Dashboard is installed as an addon but is disabled by default. To use it, you must enable both the Dashboard addon and the metrics-server addon, which collects usage metrics from your cluster.

Here’s how to enable the Dashboard and metrics-server addons:

1. **List Current Addons**: Check which addons are currently available and their states:

   ```bash
   minikube addons list
   ```

2. **Enable Metrics Server**: Activate the metrics-server addon to gather usage metrics.

   ```bash
   minikube addons enable metrics-server
   ```

3. **Enable Kubernetes Dashboard**: Now enable the Dashboard addon.

   ```bash
   minikube addons enable dashboard
   ```

4. **Verify Addon States**: Confirm that both addons are enabled:

   ```bash
   minikube addons list
   ```

5. **Open the Dashboard**: Launch the Kubernetes Dashboard in your web browser:

   ```bash
   minikube dashboard
   ```

   This command will open a new tab in your default web browser displaying the Kubernetes Dashboard.

#### Troubleshooting Access Issues

If the Dashboard does not open automatically in your browser, you can check the terminal output. Sometimes, it may provide a URL that you can manually copy and paste into your browser. To force the terminal to display the URL, run:

```bash
minikube dashboard --url
```

This command will output a URL you can use to access the Dashboard. Depending on your terminal's features, you might be able to click or right-click the URL to open it directly.

#### Expected Behavior After Reboot

After logging out or rebooting your workstation, you might notice that running `minikube dashboard` directly opens the Dashboard in your browser without needing the `--url` option. This is a typical behavior of the Minikube environment.

### Summary

The Kubernetes Dashboard is a powerful tool for managing your Kubernetes clusters visually. By enabling the necessary addons in Minikube and accessing the Dashboard, you can easily monitor and control your applications running within the cluster.

Your section on the **Kubernetes Dashboard** looks well-structured and informative! Here’s a slight refinement and additional details to enhance clarity and completeness:

---

### Kubernetes Dashboard

The **Kubernetes Dashboard** is a web-based user interface designed for managing Kubernetes clusters. It provides a visual overview of cluster resources, workloads, and configurations, simplifying interactions with and monitoring of your applications.

#### Enabling the Dashboard in Minikube

In Minikube, the Dashboard is installed as an addon but is disabled by default. To use it, you need to enable both the Dashboard addon and the metrics-server addon, which collects usage metrics from your cluster.

Here’s how to enable the Dashboard and metrics-server addons:

1. **List Current Addons**: Check the available addons and their statuses:

   ```bash
   minikube addons list
   ```

2. **Enable Metrics Server**: Activate the metrics-server addon to gather resource usage metrics.

   ```bash
   minikube addons enable metrics-server
   ```

3. **Enable Kubernetes Dashboard**: Now enable the Dashboard addon.

   ```bash
   minikube addons enable dashboard
   ```

4. **Verify Addon States**: Confirm that both addons are enabled:

   ```bash
   minikube addons list
   ```

5. **Open the Dashboard**: Launch the Kubernetes Dashboard in your web browser:

   ```bash
   minikube dashboard
   ```

   This command opens a new tab in your default web browser displaying the Kubernetes Dashboard.

#### Troubleshooting Access Issues

If the Dashboard does not open automatically in your browser, you can check the terminal output. Sometimes, it may provide a URL that you can manually copy and paste into your browser. To force the terminal to display the URL, run:

```bash
minikube dashboard --url
```

This command will output a URL for accessing the Dashboard. Depending on your terminal's capabilities, you might be able to click or right-click the URL to open it directly.

#### Expected Behavior After Reboot

After logging out or rebooting your workstation, you might notice that running `minikube dashboard` directly opens the Dashboard in your browser without needing the `--url` option. This is standard behavior in the Minikube environment.

The Kubernetes Dashboard is a powerful tool for managing your Kubernetes clusters visually. By enabling the necessary addons in Minikube and accessing the Dashboard, you can easily monitor and control your applications running within the cluster.

---

### APIs with Authentication

When not using the `kubectl proxy`, authenticating to the Kubernetes API Server is necessary for sending API requests. This can be achieved by providing a **Bearer Token** or using a set of keys and certificates.

#### Bearer Token Authentication

A **Bearer Token** is an access token generated by the authentication server (the API Server on the control plane node) upon the client's request. Using this token, the client can securely communicate with the Kubernetes API Server without providing additional authentication details. The token may need to be supplied again for subsequent resource access requests.

#### Creating an Access Token and Granting Permissions

To create an access token for the default `ServiceAccount` and grant it special permissions to access the root directory of the API, we will set up a Role-Based Access Control (RBAC) policy. This includes defining a `ClusterRole` and a `ClusterRoleBinding`. The special permission is only necessary for accessing the root directory of the API, while paths such as `/api` and `/apis` do not require it.

1. **Create the Access Token**:

   ```bash
   export TOKEN=$(kubectl create token default)
   ```

2. **Create the ClusterRole**:

   ```bash
   kubectl create clusterrole api-access-root --verb=get --non-resource-url=/*
   ```

3. **Create the ClusterRoleBinding**:

   ```bash
   kubectl create clusterrolebinding api-access-root --clusterrole=api-access-root --serviceaccount=default:default
   ```

4. **Retrieve the API Server Endpoint**:

   ```bash
   export APISERVER=$(kubectl config view | grep https | cut -f 2- -d ":" | tr -d " ")
   ```

5. **Confirm the API Server Endpoint**:

   Ensure that the `APISERVER` variable contains the same IP address as the Kubernetes control plane by running:

   ```bash
   echo $APISERVER
   ```

   It should output something like:

   ```
   https://192.168.99.100:8443
   ```

   You can also confirm this with:

   ```bash
   kubectl cluster-info
   ```

   It should output:

   ```
   Kubernetes control plane is running at https://192.168.99.100:8443 ...
   ```

#### Accessing the API Server

You can access the API Server using the `curl` command as shown below:

```bash
curl $APISERVER --header "Authorization: Bearer $TOKEN" --insecure
```

You should receive a response similar to the following, which lists available paths:

```json
{
 "paths": [
   "/api",
   "/api/v1",
   "/apis",
   "/apis/apps",
   ...
   "/logs",
   "/metrics",
   "/openapi/v2",
   "/version"
 ]
}
```

#### Accessing Specific API Groups

You can run additional `curl` commands to retrieve details about specific API groups. These commands should work even without the special permission defined above and granted to the default `ServiceAccount`:

```bash
curl $APISERVER/api/v1 --header "Authorization: Bearer $TOKEN" --insecure

curl $APISERVER/apis/apps/v1 --header "Authorization: Bearer $TOKEN" --insecure

curl $APISERVER/healthz --header "Authorization: Bearer $TOKEN" --insecure

curl $APISERVER/metrics --header "Authorization: Bearer $TOKEN" --insecure
```

#### Alternative Authentication Method

Instead of using a Bearer Token, you can extract the client certificate, client key, and certificate authority data from the `~/.kube/config` file. Once extracted, these can be encoded and passed with a `curl` command for authentication. The new command would look like this:

```bash
curl $APISERVER --cert encoded-cert --key encoded-key --cacert encoded-ca
```

> **Note**: The command above requires the client certificate, key, and CA data to be base64 encoded. This is provided for illustrative purposes and should be adapted based on your actual certificates.

---

#### 3. **Basic `kubectl` Commands**

- **Check Nodes in the Cluster**:
  A node represents a machine (physical or virtual) running Kubernetes. Since Minikube runs a single-node cluster, it will show just one node.
  ```bash
  kubectl get nodes
  ```

- **View Cluster Information**:
  Retrieve details about the cluster components:
  ```bash
  kubectl cluster-info
  ```

- **List Running Pods**:
  Pods are the smallest units in Kubernetes, containing one or more containers. You can view all running pods in your cluster.
  ```bash
  kubectl get pods
  ```
- **Get Detailed Pod Information**:
  To get detailed information about a specific pod, including its configuration, status, and events:
  ```bash
  kubectl describe pod <pod-name>
  ```
- **View Services**:
  Services in Kubernetes expose your pods to the network.
  ```bash
  kubectl get services
  ```
#### What is Service: 
Service is a method for exposing a network application that is running as one or more Pods in your cluster.
Each Service object defines a logical set of endpoints (usually these endpoints are Pods) along with a policy about how to make those pods accessible.

**More about Service:** 
- https://kubernetes.io/docs/concepts/services-networking/service/
- https://kubernetes.io/docs/tutorials/services/connect-applications-service/


#### 4. **Deploy an Application**
You can deploy applications in Kubernetes by creating a **deployment**. A deployment manages a set of identical pods to ensure availability.

- **Create a Deployment**:
  Deploy an example app using the `nginx` image:
  ```bash
  kubectl create deployment nginx-app --image=nginx
  ```

- **View the Deployment**:
  To verify the deployment is created successfully, use:
  ```bash
  kubectl get deployments
  ```

- **Expose the Deployment as a Service**:
  Once your application is deployed, you can expose it via a service to make it accessible from outside the cluster:
  ```bash
  kubectl expose deployment nginx-app --type=NodePort --port=80
  ```

- **Access the Application**:
  Use Minikube to get the URL of the service:
  ```bash
  minikube service nginx-app --url
  ```



### get pod in detail:

The following command is used in Kubernetes to retrieve detailed information about the Pods in a specific namespace or in the current context.

```
kubectl get pod -o wide
```

  - **`-o wide`**: This flag changes the output format to include additional details, such as:
  - **Node**: The node on which the Pod is running.
  - **IP Address**: The Pod's IP address.
  - **Container Status**: Status of the containers within the Pod, including the number of restarts.
  - **Container Images**: The images used by the containers in the Pod.

The output might look like this:

```
NAME            READY   STATUS    RESTARTS   AGE     IP            NODE
nginx-pod      1/1     Running   0          5m      10.244.1.5    worker-node-1
app-pod        1/1     Running   2          10m     10.244.1.6    worker-node-2
```

#### 5. **Scaling the Application**
Kubernetes allows you to scale your application easily by increasing or decreasing the number of pods in a deployment.

- **Scale the Deployment**:
  To scale the number of replicas (pods) to 3:
  ```bash
  kubectl scale deployment nginx-app --replicas=3
  ```

- **Verify the Scaling**:
  Check the number of pods to ensure scaling worked:
  ```bash
  kubectl get pods
  ```

#### 6. **Updating Applications**
You can update your application by changing the container image used in the deployment.

- **Update the Image in a Deployment**:
  Update the nginx app to use version `1.19`:
  ```bash
  kubectl set image deployment/nginx-app nginx=nginx:1.19
  ```

- **Monitor the Update**:
  View the status of the rolling update:
  ```bash
  kubectl rollout status deployment/nginx-app
  ```

- **Rollback an Update**:
  If the update causes issues, you can easily roll back to the previous version:
  ```bash
  kubectl rollout undo deployment/nginx-app
  ```

#### 7. **Deleting Resources**
Once you're done with your deployments, services, or any other resources, you can delete them using `kubectl`.

- **Delete a Deployment**:
  To remove the nginx-app deployment:
  ```bash
  kubectl delete deployment nginx-app
  ```

- **Delete a Service**:
  Similarly, to remove the service:
  ```bash
  kubectl delete service nginx-app
  ```

#### 8. **Using Namespaces**
Namespaces are a way to divide cluster resources between multiple users or projects.

- **View All Namespaces**:
  ```bash
  kubectl get namespaces
  ```

- **Create a New Namespace**:
  ```bash
  kubectl create namespace dev
  ```

- **Use a Different Namespace**:
  To create resources within a specific namespace:
  ```bash
  kubectl create deployment nginx-app --image=nginx --namespace=dev
  ```

- **Switch Between Namespaces**:
  You can specify which namespace `kubectl` should interact with:
  ```bash
  kubectl config set-context --current --namespace=dev
  ```

#### 9. **Debugging with `kubectl`**

- **View Logs of a Pod**:
  You can troubleshoot issues by viewing the logs generated by a pod:
  ```bash
  kubectl logs <pod-name>
  ```

- **Get a Shell Inside a Pod**:
  For deeper debugging, you can connect to a running container within a pod:
  ```bash
  kubectl exec -it <pod-name> -- /bin/bash
  ```

- **Describe Resources for Troubleshooting**:
  To view detailed resource events and configurations, use:
  ```bash
  kubectl describe <resource-type> <resource-name>
  ```
  Example:
  ```bash
  kubectl describe pod nginx-app
  ```

#### 10. **Port Forwarding**
Expose an application running in a pod to your local machine via port forwarding:
```bash
kubectl port-forward deployment/nginx-app 8080:80
```
This will map port `8080` on your local machine to port `80` inside the pod.

#### 11. **Working with YAML Files**
You can also define resources in YAML configuration files and apply them using `kubectl`.

- **Apply a YAML File**:
  ```bash
  kubectl apply -f <filename>.yaml
  ```

- **View Resource Definitions in YAML**:
  You can output any resource's configuration in YAML:
  ```bash
  kubectl get <resource-type> <resource-name> -o yaml
  ```

#### 12. **Cleanup**

- **Delete All Resources**:
  To remove all resources (pods, services, deployments, etc.) in the default namespace:
  ```bash
  kubectl delete all --all
  ```
#### Learning More About kubectl
Additional details, advanced usage, and command options for `kubectl` can be found in:

- The [kubectl book](https://kubernetes.io/docs/reference/kubectl/), which covers all aspects of the tool.
- The [official Kubernetes documentation](https://kubernetes.io/docs/).
- The [kubectl GitHub repository](https://github.com/kubernetes/kubectl), for version history and releases. 

By mastering `kubectl`, operators and developers can efficiently manage Kubernetes clusters and streamline day-to-day operations.
