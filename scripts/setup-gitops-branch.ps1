# PowerShell script to set up GitOps branch for ArgoCD
# This script creates a gitops branch and copies Kubernetes manifests

Write-Host "Setting up GitOps branch..." -ForegroundColor Green

# Check if gitops branch exists
$branchExists = git show-ref --verify --quiet refs/heads/gitops
if ($LASTEXITCODE -eq 0) {
    Write-Host "GitOps branch already exists. Switching to it..." -ForegroundColor Yellow
    git checkout gitops
} else {
    Write-Host "Creating new GitOps branch..." -ForegroundColor Yellow
    git checkout -b gitops
}

# Ensure k8s directory exists
if (-not (Test-Path "k8s")) {
    Write-Host "Error: k8s directory not found!" -ForegroundColor Red
    exit 1
}

# Add and commit k8s manifests
git add k8s/
$hasChanges = git diff --staged --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to commit in k8s directory." -ForegroundColor Yellow
} else {
    git commit -m "Add Kubernetes manifests for GitOps deployment"
    Write-Host "Committed Kubernetes manifests." -ForegroundColor Green
}

Write-Host ""
Write-Host "GitOps branch setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update k8s/app-deploy.yaml with your container registry image"
Write-Host "2. Update k8s/argocd-application.yml with your repository URL"
Write-Host "3. Update k8s/secret.yml with secure database credentials"
Write-Host "4. Push the branch: git push origin gitops"
Write-Host "5. Apply ArgoCD Application: kubectl apply -f k8s/argocd-application.yml"

