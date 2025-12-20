#!/bin/bash

# Create directory structure
mkdir -p monitoring/{prometheus,grafana,alertmanager}/
mkdir -p monitoring/prometheus/{rules,recording-rules}/
mkdir -p monitoring/docs/

# Create necessary files
touch monitoring/prometheus/prometheus-configmap.yaml
touch monitoring/prometheus/prometheus-deployment.yaml
touch monitoring/prometheus/prometheus-service.yaml
touch monitoring/prometheus/prometheus-rbac.yaml

touch monitoring/grafana/grafana-configmap.yaml
touch monitoring/grafana/grafana-deployment.yaml
touch monitoring/grafana/grafana-service.yaml
touch monitoring/grafana/grafana-datasource.yaml

touch monitoring/alertmanager/alertmanager-configmap.yaml
touch monitoring/alertmanager/alertmanager-deployment.yaml
touch monitoring/alertmanager/alertmanager-service.yaml

# Make script executable
chmod +x setup.sh
