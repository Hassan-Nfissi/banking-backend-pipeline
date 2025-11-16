# CI/CD Pipeline Setup with Kubernetes and ArgoCD GitOps

This guide will help you set up a complete CI/CD pipeline for the banking backend application using GitHub Actions, Docker, Kubernetes, and ArgoCD.

## Overview

- **CI Pipeline**: Builds, tests, and pushes Docker images to GitHub Container Registry
- **CD Pipeline**: Uses GitOps with ArgoCD to deploy to Kubernetes
- **GitOps Branch**: Separate branch (`gitops`) containing Kubernetes manifests

## Prerequisites

1. GitHub repository
2. Kubernetes cluster (local or cloud)
3. ArgoCD installed in your cluster
4. kubectl configured to access your cluster
5. Docker installed (for local testing)

## Step 1: Configure GitHub Actions

### 1.1 Update Container Registry

The CI/CD pipeline uses GitHub Container Registry. Update the image name in `.github/workflows/ci-cd.yml` if needed.

### 1.2 Set up GitHub Secrets (if using private registry)

If you're using a different container registry, add secrets:
- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`

## Step 2: Set up GitOps Branch

### Option A: Using the Setup Script (Recommended)

**Linux/Mac:**
```bash
chmod +x scripts/setup-gitops-branch.sh
./scripts/setup-gitops-branch.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup-gitops-branch.ps1
```

### Option B: Manual Setup

```bash
# Create and switch to gitops branch
git checkout -b gitops

# Add k8s manifests
git add k8s/

# Commit
git commit -m "Add Kubernetes manifests for GitOps"

# Push to remote
git push origin gitops
```

## Step 3: Update Kubernetes Manifests

Before deploying, update these files:

### 3.1 Update Container Image (`k8s/app-deploy.yaml`)

Replace `YOUR_USERNAME` with your GitHub username:

```yaml
image: ghcr.io/YOUR_USERNAME/banking-backend-pipeline:latest
```

### 3.2 Update Repository URL (`k8s/argocd-application.yml`)

Replace `YOUR_USERNAME` and repository name:

```yaml
repoURL: https://github.com/YOUR_USERNAME/banking-backend-pipeline.git
```

### 3.3 Update Database Secrets (`k8s/secret.yml`)

**Important**: For production, use a secure method to manage secrets:

```bash
# Option 1: Use kubectl to create secret
kubectl create secret generic banking-secrets \
  --from-literal=db-password='your-secure-password' \
  --from-literal=db-username='root' \
  --from-literal=db-name='banking_db' \
  -n banking

# Option 2: Use Sealed Secrets
# Install: https://github.com/bitnami-labs/sealed-secrets
```

### 3.4 Update Ingress Domain (`k8s/app-deploy.yaml`)

Replace `banking-api.example.com` with your domain:

```yaml
- host: banking-api.yourdomain.com
```

## Step 4: Install ArgoCD (if not already installed)

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD UI at: `https://localhost:8080`
- Username: `admin`
- Password: (from the command above)

## Step 5: Deploy ArgoCD Application

```bash
# Apply the ArgoCD Application manifest
kubectl apply -f k8s/argocd-application.yml

# Check application status
kubectl get applications -n argocd
```

## Step 6: Verify Deployment

```bash
# Check pods
kubectl get pods -n banking

# Check services
kubectl get svc -n banking

# Check ingress
kubectl get ingress -n banking

# View application logs
kubectl logs -f deployment/banking-app-deployment -n banking
```

## Step 7: Test the Pipeline

1. Make a change to your code
2. Commit and push to `main` branch
3. GitHub Actions will:
   - Build and test the application
   - Build and push Docker image
   - Update GitOps branch with new image tag
4. ArgoCD will detect the change and deploy automatically

## CI/CD Workflow

```
┌─────────────┐
│   Code Push │
│  (main/dev) │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  GitHub Actions │
│  - Build & Test │
│  - Build Image  │
│  - Push to GHCR │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│  Update GitOps  │
│     Branch      │
│  (image tag)    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│    ArgoCD       │
│  - Detect Change│
│  - Sync Manifests│
│  - Deploy to K8s │
└─────────────────┘
```

## Troubleshooting

### ArgoCD Application Not Syncing

1. Check application status:
   ```bash
   kubectl describe application banking-backend -n argocd
   ```

2. Check ArgoCD logs:
   ```bash
   kubectl logs -f deployment/argocd-application-controller -n argocd
   ```

### Pods Not Starting

1. Check pod status:
   ```bash
   kubectl describe pod <pod-name> -n banking
   ```

2. Check events:
   ```bash
   kubectl get events -n banking --sort-by='.lastTimestamp'
   ```

### Database Connection Issues

1. Verify MySQL is running:
   ```bash
   kubectl get pods -n banking | grep mysql
   ```

2. Check MySQL logs:
   ```bash
   kubectl logs -f deployment/mysql-deployment -n banking
   ```

3. Test connection:
   ```bash
   kubectl exec -it deployment/mysql-deployment -n banking -- mysql -u root -p
   ```

## Production Recommendations

1. **Secrets Management**: Use Sealed Secrets, External Secrets Operator, or HashiCorp Vault
2. **Database**: Use managed database services (AWS RDS, Google Cloud SQL, Azure Database)
3. **Storage**: Use cloud provider storage classes instead of hostPath
4. **Monitoring**: Add Prometheus and Grafana
5. **Logging**: Add ELK stack or Loki
6. **TLS**: Configure cert-manager for automatic TLS certificates
7. **Resource Limits**: Adjust based on your workload
8. **High Availability**: Configure multiple replicas and pod disruption budgets
9. **Backup**: Set up database backups
10. **Security**: Enable network policies, use RBAC, scan images for vulnerabilities

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [GitHub Actions](https://docs.github.com/en/actions)

