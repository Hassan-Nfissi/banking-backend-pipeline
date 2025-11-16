#!/bin/bash

# Script to set up GitOps branch for ArgoCD
# This script creates a gitops branch and copies Kubernetes manifests

set -e

echo "Setting up GitOps branch..."

# Check if gitops branch exists
if git show-ref --verify --quiet refs/heads/gitops; then
    echo "GitOps branch already exists. Switching to it..."
    git checkout gitops
else
    echo "Creating new GitOps branch..."
    git checkout -b gitops
fi

# Ensure k8s directory exists
if [ ! -d "k8s" ]; then
    echo "Error: k8s directory not found!"
    exit 1
fi

# Add and commit k8s manifests
git add k8s/
if git diff --staged --quiet; then
    echo "No changes to commit in k8s directory."
else
    git commit -m "Add Kubernetes manifests for GitOps deployment"
    echo "Committed Kubernetes manifests."
fi

echo ""
echo "GitOps branch setup complete!"
echo ""
echo "Next steps:"
echo "1. Update k8s/app-deploy.yaml with your container registry image"
echo "2. Update k8s/argocd-application.yml with your repository URL"
echo "3. Update k8s/secret.yml with secure database credentials"
echo "4. Push the branch: git push origin gitops"
echo "5. Apply ArgoCD Application: kubectl apply -f k8s/argocd-application.yml"

