# Kubernetes Multi-Environment Deployment Architecture

Production-grade Kubernetes cluster setup with deployment strategies, security best practices, and operational excellence across development, staging, and production environments.

## Overview

This project demonstrates:
- **Multi-environment Kubernetes deployments** (dev, staging, prod)
- **Workload orchestration** with rolling updates and health probes
- **Service discovery and networking** with Ingress controllers
- **Configuration management** using ConfigMaps and Secrets
- **Persistent storage** for stateful applications
- **Security policies** and RBAC
- **Auto-scaling** with Horizontal Pod Autoscaler (HPA)
- **Monitoring and logging** integration

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Internet Users                        │
└──────────────────────┬─────────────────────────────────┘
                       │
        ┌──────────────▼──────────────┐
        │   Ingress Controller        │
        │  (ALB / NGINX / Traefik)    │
        └──────────────┬──────────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
┌───▼────┐        ┌────▼────┐       ┌────▼────┐
│  Dev   │        │ Staging │       │   Prod  │
│Cluster │        │ Cluster │       │ Cluster │
└────┬───┘        └────┬────┘       └────┬────┘
     │                 │                 │
   ┌─┴─┐            ┌──┴──┐          ┌──┴──┐
   │Pod│  ┌─────┐   │Pod  │  ┌─────┐│Pod  │ ┌─────┐
   │   │  │Svc  │   │     │  │Svc  ││     │ │Svc  │
   └───┘  └──┬──┘   └─────┘  └──┬──┘└─────┘ └──┬──┘
             │                   │              │
          ┌──▼──────────────────▼──────────────▼──┐
          │      Persistent Volume Storage        │
          │      (EBS / EFS / S3)                 │
          └─────────────────────────────────────┘
```

## Key Features

### Multi-Environment Setup
- **Development:** Fast iteration, minimal resources
- **Staging:** Production-like environment for testing
- **Production:** High availability, security-hardened, monitored

### Workload Orchestration
- Rolling updates with zero downtime
- Readiness and liveness probes
- Resource requests and limits
- Deployment strategies (Rolling, Blue/Green, Canary-ready)

### Networking & Service Discovery
- Ingress for external traffic routing
- Service-to-service communication
- Network policies for security
- DNS-based service discovery

### Configuration Management
- ConfigMaps for non-sensitive data
- Secrets for credentials and API keys
- Volume mounts for application config
- Environment variable injection

### Security
- RBAC (Role-Based Access Control)
- Pod Security Policies
- Network policies
- Resource quotas per namespace
- Secret encryption at rest

### Scalability
- Horizontal Pod Autoscaler (HPA)
- CPU and memory-based scaling
- Custom metrics support
- Min/max replica limits

## Project Structure

```
kubernetes-deployment-guide/
├── manifests/
│   ├── dev/
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── staging/
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── hpa.yaml
│   └── prod/
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── hpa.yaml
│       ├── networkpolicy.yaml
│       ├── poddisruptionbudget.yaml
│       └── secrets.yaml
├── scripts/
│   ├── deploy.sh
│   ├── rollback.sh
│   ├── health-check.sh
│   └── scale.sh
├── monitoring/
│   ├── prometheus-config.yaml
│   ├── grafana-dashboard.json
│   └── alerts.yaml
├── troubleshooting/
│   ├── DEBUG.md
│   ├── common-issues.md
│   └── recovery-procedures.md
└── README.md
```

## Prerequisites

- Kubernetes cluster (EKS, GKE, AKS, or self-managed)
- kubectl CLI configured
- Helm 3+ (optional, for package management)
- Access to container registry (Docker Hub, ECR, ACR)

## Installation & Deployment

### 1. Clone the repository
```bash
git clone https://github.com/omer-taha/kubernetes-deployment-guide.git
cd kubernetes-deployment-guide
```

### 2. Setup cluster contexts (if multiple clusters)
```bash
# View current context
kubectl config current-context

# Switch between environments
kubectl config use-context dev-cluster
kubectl config use-context staging-cluster
kubectl config use-context prod-cluster
```

### 3. Create namespaces
```bash
kubectl apply -f manifests/dev/namespace.yaml
kubectl apply -f manifests/staging/namespace.yaml
kubectl apply -f manifests/prod/namespace.yaml
```

### 4. Deploy to development environment
```bash
kubectl apply -f manifests/dev/ --namespace=dev
kubectl get deployments -n dev
kubectl get pods -n dev
```

### 5. Deploy to staging
```bash
kubectl apply -f manifests/staging/ --namespace=staging
kubectl rollout status deployment/app-deployment -n staging
```

### 6. Deploy to production
```bash
# Use the deployment script for safety
./scripts/deploy.sh prod
```

### 7. Verify deployments
```bash
kubectl get all -n prod
kubectl describe deployment app-deployment -n prod
```

## Configuration

### Deployment Manifest Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  namespace: prod
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myregistry.azurecr.io/myapp:v1.0.0
        ports:
        - containerPort: 8080
        
        # Resource management
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Health probes
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # Environment variables
        env:
        - name: ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: environment
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db_password
```

### ConfigMap Example
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: prod
data:
  environment: "production"
  log_level: "info"
  api_timeout: "30s"
```

### Service Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: prod
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

## Monitoring & Observability

### View logs
```bash
# Latest logs
kubectl logs deployment/app-deployment -n prod --tail=100

# Follow logs (like tail -f)
kubectl logs deployment/app-deployment -n prod -f

# Logs from specific pod
kubectl logs pod-name -n prod
```

### Monitor resource usage
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods -n prod
```

### Describe resources
```bash
kubectl describe deployment app-deployment -n prod
kubectl describe pod pod-name -n prod
kubectl describe service app-service -n prod
```

## Rolling Updates & Deployments

### Update image
```bash
kubectl set image deployment/app-deployment \
  app=myregistry/myapp:v1.1.0 \
  -n prod
```

### Check rollout status
```bash
kubectl rollout status deployment/app-deployment -n prod
```

### Rollback to previous version
```bash
./scripts/rollback.sh prod
# or manually:
kubectl rollout undo deployment/app-deployment -n prod
```

### Pause/Resume rollout
```bash
kubectl rollout pause deployment/app-deployment -n prod
kubectl rollout resume deployment/app-deployment -n prod
```

## Auto-Scaling Configuration

### Horizontal Pod Autoscaler (HPA)
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-deployment
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Monitor HPA
```bash
kubectl get hpa -n prod
kubectl describe hpa app-hpa -n prod
```

## Security Best Practices

✅ RBAC enabled per environment  
✅ Network policies restrict traffic  
✅ Pod security policies enforced  
✅ Secrets encrypted at rest  
✅ Resource quotas per namespace  
✅ Security contexts (runAsNonRoot, readOnlyRootFilesystem)  
✅ Image scanning for vulnerabilities  

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod pod-name -n prod
kubectl logs pod-name -n prod
```

### Deployment stuck
```bash
kubectl rollout status deployment/app-deployment -n prod
kubectl get events -n prod --sort-by=.metadata.creationTimestamp
```

### Service not accessible
```bash
kubectl get endpoints -n prod
kubectl get ingress -n prod
kubectl describe ingress app-ingress -n prod
```

## Additional Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [CKAD Exam Guide](https://kubernetes.io/docs/reference/kubernetes-api/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## License

MIT License

## 👤 Author

**Omer Taha**  
Cloud Engineer | AWS Solutions Architect Professional | CKAD  
LinkedIn: [linkedin.com/in/omar-taha-ah](https://linkedin.com/in/omar-taha-ah)

---

**Last Updated:** January 2026  
**Kubernetes Version:** 1.24+
