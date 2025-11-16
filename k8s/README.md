# Kubernetes Manifests for Banking Backend

This directory contains Kubernetes manifests for deploying the banking backend application using GitOps with ArgoCD.

## Structure

- `namespace.yml` - Kubernetes namespace
- `secret.yml` - Secrets for database credentials
- `configmap.yml` - Configuration values
- `pv.yml` - Persistent Volume for MySQL
- `pvc.yml` - Persistent Volume Claim
- `db-deploy.yml` - MySQL database deployment and service
- `app-deploy.yaml` - Application deployment, service, and ingress
- `kustomization.yml` - Kustomize configuration
- `argocd-application.yml` - ArgoCD Application manifest

## Prerequisites

1. Kubernetes cluster (v1.24+)
2. ArgoCD installed in your cluster
3. NGINX Ingress Controller (for Ingress)
4. Storage class configured (for PVC)

## Setup Instructions

### 1. Update Configuration

Before deploying, update the following:

- **Image Registry**: Update the image path in `app-deploy.yaml` with your container registry
- **Repository URL**: Update the repo URL in `argocd-application.yml`
- **Domain**: Update the host in `app-deploy.yaml` ingress section
- **Secrets**: Update database password in `secret.yml` or use sealed-secrets

### 2. Create GitOps Branch

```bash
git checkout -b gitops
git add k8s/
git commit -m "Add Kubernetes manifests for GitOps"
git push origin gitops
```

### 3. Deploy ArgoCD Application

```bash
kubectl apply -f k8s/argocd-application.yml
```

### 4. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD at `https://localhost:8080` (default credentials: admin / password from secret)

## Manual Deployment (without ArgoCD)

If you want to deploy manually:

```bash
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/secret.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/db-deploy.yml
kubectl apply -f k8s/app-deploy.yaml
```

## Production Considerations

1. **Secrets Management**: Use Sealed Secrets, External Secrets Operator, or Vault
2. **Storage**: Use cloud provider storage classes instead of hostPath
3. **Database**: Consider using managed database services (RDS, Cloud SQL, etc.)
4. **Monitoring**: Add Prometheus and Grafana
5. **Logging**: Add ELK stack or Loki
6. **TLS**: Configure cert-manager for automatic TLS certificates
7. **Resource Limits**: Adjust based on your workload
8. **High Availability**: Configure multiple replicas and pod disruption budgets

## Health Checks

The application uses Spring Boot Actuator for health checks. Make sure to add the actuator dependency:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

And configure it in `application.yml`:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      probes:
        enabled: true
```

