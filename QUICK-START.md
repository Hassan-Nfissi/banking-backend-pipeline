# Quick Start Guide - CI/CD with GitOps

## 🚀 Quick Setup (5 minutes)

### 1. Update Configuration Files

**Update `k8s/app-deploy.yaml`:**
```yaml
# Line ~20: Replace YOUR_USERNAME with your GitHub username
image: ghcr.io/YOUR_USERNAME/banking-backend-pipeline:latest
```

**Update `k8s/argocd-application.yml`:**
```yaml
# Line ~7: Replace with your repository URL
repoURL: https://github.com/YOUR_USERNAME/banking-backend-pipeline.git
```

**Update `k8s/app-deploy.yaml` (Ingress):**
```yaml
# Line ~80: Replace with your domain
- host: banking-api.yourdomain.com
```

### 2. Create GitOps Branch

**Windows (PowerShell):**
```powershell
.\scripts\setup-gitops-branch.ps1
git push origin gitops
```

**Linux/Mac:**
```bash
chmod +x scripts/setup-gitops-branch.sh
./scripts/setup-gitops-branch.sh
git push origin gitops
```

### 3. Install ArgoCD (if needed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 4. Deploy ArgoCD Application

```bash
kubectl apply -f k8s/argocd-application.yml
```

### 5. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Visit: `https://localhost:8080`
- Username: `admin`
- Password: (from step 3)

## 📋 File Structure

```
banking-backend-pipeline/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # CI/CD pipeline
├── k8s/                        # Kubernetes manifests (GitOps branch)
│   ├── namespace.yml
│   ├── secret.yml
│   ├── configmap.yml
│   ├── pv.yml
│   ├── pvc.yml
│   ├── db-deploy.yml          # MySQL deployment
│   ├── app-deploy.yaml        # App deployment
│   ├── kustomization.yml
│   ├── argocd-application.yml # ArgoCD app
│   └── README.md
├── scripts/
│   ├── setup-gitops-branch.sh
│   └── setup-gitops-branch.ps1
├── Dockerfile
├── .dockerignore
└── CI-CD-SETUP.md             # Detailed setup guide
```

## 🔄 Workflow

1. **Push to main** → GitHub Actions builds & pushes image
2. **GitOps branch updated** → ArgoCD detects change
3. **ArgoCD syncs** → Deploys to Kubernetes

## ✅ Verify Deployment

```bash
# Check pods
kubectl get pods -n banking

# Check services
kubectl get svc -n banking

# View logs
kubectl logs -f deployment/banking-app-deployment -n banking
```

## 🔧 Common Commands

```bash
# Sync ArgoCD application manually
argocd app sync banking-backend

# Check ArgoCD application status
kubectl get application banking-backend -n argocd

# Restart deployment
kubectl rollout restart deployment/banking-app-deployment -n banking

# Scale deployment
kubectl scale deployment banking-app-deployment --replicas=3 -n banking
```

## 🐛 Troubleshooting

**Application not syncing?**
```bash
kubectl describe application banking-backend -n argocd
```

**Pods not starting?**
```bash
kubectl describe pod <pod-name> -n banking
kubectl logs <pod-name> -n banking
```

**Database connection issues?**
```bash
kubectl logs -f deployment/mysql-deployment -n banking
```

## 📚 Next Steps

- Read `CI-CD-SETUP.md` for detailed instructions
- Read `k8s/README.md` for Kubernetes manifest details
- Configure secrets management for production
- Set up monitoring and logging

