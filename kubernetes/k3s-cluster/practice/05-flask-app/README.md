# Deploying Flask Application on K3s

This guide demonstrates how to deploy a simple Flask application on K3s using Docker and Kubernetes.

## Project Structure

```
05-flask-app/
├── app/
│   ├── app.py
│   └── requirements.txt
├── kubernetes/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
└── README.md
```

## Step 1: Create the Flask Application

1. First, ensure you have the necessary Python tools:

```bash
sudo apt update
sudo apt install python3-venv python3-pip
```

2. Set up Python virtual environment:

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate
```

3. Create requirements.txt with these versions:

```bash
cd app
cat > requirements.txt << EOF
flask==2.3.3
werkzeug==2.3.7
EOF
```

4. Install dependencies:

```bash
pip install -r requirements.txt
```

5. Test the application:

```bash
python3 app.py
# In another terminal:
curl http://localhost:5000
```

6. When done, deactivate the virtual environment:

```bash
deactivate
```

## Step 2: Build and Test Docker Image

1. Build the image (choose one of the following approaches):

   ```bash
   # For local K3s deployment
   docker build -t localhost:5000/flask-k3s:v1 .

   # For GitHub Container Registry
   docker build -t ghcr.io/<your-github-username>/flask-k3s:v1 .
   ```

2. Choose your deployment method:

   ### Option A: Local K3s Deployment

   ```bash
   # Save the Docker image to a file
   docker save localhost:5000/flask-k3s:v1 > flask-app.tar

   # Import the image into K3s
   sudo k3s ctr images import flask-app.tar
   ```

   ### Option B: GitHub Container Registry

   ```bash
   # Login to GitHub Container Registry
   echo $GITHUB_PAT | docker login ghcr.io -u <your-github-username> --password-stdin

   # Push the image
   docker push ghcr.io/<your-github-username>/flask-k3s:v1

   # Make your repository public in GitHub packages settings
   # Navigate to: https://github.com/settings/packages
   ```

3. Update Kubernetes manifests:

   For local deployment, use:

   ```yaml
   image: localhost:5000/flask-k3s:v1
   imagePullPolicy: Never
   ```

   For GitHub Container Registry, use:

   ```yaml
   image: ghcr.io/<your-github-username>/flask-k3s:v1
   imagePullPolicy: Always
   ```

## Step 3: Deploy to K3s

1. If using GitHub Container Registry, add pull secret:

   ```bash
   # Create GitHub token secret
   kubectl create secret docker-registry ghcr-login-secret \
     --docker-server=ghcr.io \
     --docker-username=<your-github-username> \
     --docker-password=<your-github-pat>

   # Add to service account (optional)
   kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ghcr-login-secret"}]}'
   ```

2. Apply Kubernetes manifests:
   ```bash
   kubectl apply -f kubernetes/
   ```

## Step 4: Scale and Update

1. Scale the deployment:

```bash
kubectl scale deployment flask-app --replicas=3
```

2. Update the application:

```bash
# Make changes to app.py
docker build -t flask-k3s:v2 .
kubectl set image deployment/flask-app flask-app=flask-k3s:v2
```

## Troubleshooting

1. Check pod status:

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

2. View logs:

```bash
kubectl logs <pod-name>
```

3. Common issues:

- ImagePullBackOff: Check image name and availability
- CrashLoopBackOff: Check application logs
- Port conflicts: Ensure service ports are available

4. Virtual Environment Issues:

   - If `pip install` fails, ensure you're in the virtual environment (you should see `(venv)` in your prompt)
   - If Flask fails to start, verify you're using the correct versions in requirements.txt
   - To start fresh, delete the `venv` directory and recreate it

5. Image Pull Issues:

   - For local images: Ensure image is imported into K3s
   - For GitHub Registry: Check secret configuration and image visibility
   - Verify image tag matches deployment manifest

   ```bash
   # Check available images in K3s
   sudo k3s crictl images

   # Check pull secrets
   kubectl get secrets
   ```
