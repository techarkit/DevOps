# K3s Kubernetes Learning Project

A comprehensive guide and collection of resources for learning Kubernetes using K3s.

## Introduction

K3s is a lightweight, certified Kubernetes distribution designed for resource-constrained environments and edge computing. It offers several advantages:

### What is K3s?

- **Lightweight**: A single binary less than 100MB that includes all Kubernetes master and worker components
- **Production-ready**: Fully CNCF certified Kubernetes distribution
- **Simple to install**: Single command installation process
- **Low resource usage**: Requires only 512MB RAM and 200MB disk space per node
- **Production grade**: Suitable for everything from development to production environments

### Key Features

- Built-in containerd runtime
- Integrated SQLite database (can be replaced with etcd or other databases)
- Automatic TLS management
- Built-in service load balancer (ServiceLB)
- Local storage provider
- Helm controller for easy application deployment
- Simplified installation of common applications

### Use Cases

- Edge computing and IoT
- Development environments
- CI/CD pipelines
- Resource-constrained environments
- Learning and education
- Small to medium production deployments

## Table of Contents

- [Getting Started](#getting-started)
- [Cluster Setup](#cluster-setup)
- [Basic Operations](#basic-operations)
- [Practice Exercises](#practice-exercises)
- [Monitoring](#monitoring)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Prerequisites

- Linux machine with at least 2GB RAM
- Access to terminal with sudo privileges
- Basic understanding of containers
- kubectl CLI tool (installed automatically with K3s)

### Quick Start

1. **Install K3s Server (Master Node)**

   ```bash
   curl -sfL https://get.k3s.io | sh -
   # Wait ~30 seconds for the installation to complete
   ```

2. **Verify Installation**

   ```bash
   sudo k3s kubectl get nodes
   ```

3. **Set up kubectl access for your user**
   ```bash
   mkdir ~/.kube
   sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
   sudo chown $USER:$USER ~/.kube/config
   ```

## Cluster Setup

### Single-Node Development Setup

For local development and learning, a single-node setup is recommended:

1. **Verify your node is running:**

   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

2. **Access your cluster:**

   ```bash
   # Set up kubectl config
   mkdir -p ~/.kube
   sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
   sudo chown $USER:$USER ~/.kube/config
   export KUBECONFIG=~/.kube/config
   ```

3. **Test the setup:**

   ```bash
   # Deploy a test application
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80 --type=NodePort

   # Get the assigned port
   kubectl get svc nginx
   ```

### Resource Management

Since you're running on a single machine, be mindful of resource usage:

- Monitor resource usage: `kubectl top nodes` (requires metrics-server)
- Set resource limits in your deployments
- Clean up unused resources: `kubectl delete pod,deployment,svc --all`

## Basic Operations

### Common kubectl Commands

```bash
# View all resources
kubectl get all --all-namespaces

# Deploy an application
kubectl apply -f manifests/

# View logs
kubectl logs <pod-name>

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/sh
```

## Practice Exercises

This repository includes several practice exercises:

1. [Basic Pod Deployment](./practice/01-basic-pod/)
2. [ConfigMaps and Secrets](./practice/02-configs/)
3. [Service Discovery](./practice/03-services/)
4. [Persistent Storage](./practice/04-storage/)

## Monitoring

We use the following tools for monitoring:

- Prometheus for metrics collection
- Grafana for visualization
- See [monitoring setup guide](./monitoring/README.md)

## Common Patterns

- [Blue-Green Deployments](./patterns/blue-green/)
- [Canary Releases](./patterns/canary/)
- [Sidecar Patterns](./patterns/sidecar/)

## Troubleshooting

Common issues and solutions:

1. **Pod in CrashLoopBackOff**

   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name> --previous
   ```

2. **Service Discovery Issues**
   ```bash
   kubectl get endpoints
   kubectl describe service <service-name>
   ```

For more examples and practice materials, check the `practice/` directory.
