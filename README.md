# K8S Production-Ready Platform

Portfolio project demonstrating mid-level Kubernetes engineering — full infrastructure stack, zero application code.

---

## Goals

- Learn and showcase real-world Kubernetes patterns
- Build a GitOps-driven, multi-environment platform from scratch
- Cover the stack a mid-level K8S engineer is expected to know

---

## Architecture Overview

```
                        ┌─────────────────────────────────────┐
                        │           GitHub Repository          │
                        │  (source of truth for all manifests) │
                        └──────────────────┬──────────────────┘
                                           │ watches
                                           ▼
                        ┌─────────────────────────────────────┐
                        │              ArgoCD                  │
                        │    (GitOps controller + AppSet)      │
                        └──────┬───────────────────┬──────────┘
                               │ syncs             │ syncs
                    ┌──────────▼───────┐  ┌────────▼─────────┐
                    │   Namespace: dev │  │ Namespace: prod   │
                    │                  │  │                   │
                    │  ┌────────────┐  │  │  ┌────────────┐  │
                    │  │   NGINX    │  │  │  │   NGINX    │  │
                    │  │  (proxy)   │  │  │  │  (proxy)   │  │
                    │  └─────┬──────┘  │  │  └─────┬──────┘  │
                    │        │         │  │        │          │
                    │  ┌─────▼──────┐  │  │  ┌─────▼──────┐  │
                    │  │  Frontend  │  │  │  │  Frontend  │  │
                    │  └─────┬──────┘  │  │  └─────┬──────┘  │
                    │        │         │  │        │          │
                    │  ┌─────▼──────┐  │  │  ┌─────▼──────┐  │
                    │  │ API Gateway│  │  │  │ API Gateway│  │
                    │  └──┬──────┬──┘  │  │  └──┬──────┬──┘  │
                    │     │      │     │  │     │      │      │
                    │  ┌──▼──┐ ┌─▼──┐  │  │  ┌──▼──┐ ┌─▼──┐  │
                    │  │auth │ │rpt │  │  │  │auth │ │rpt │  │
                    │  └──┬──┘ └─┬──┘  │  │  └──┬──┘ └─┬──┘  │
                    │     └──┬───┘     │  │     └──┬───┘      │
                    │  ┌─────▼──────┐  │  │  ┌─────▼──────┐  │
                    │  │ PostgreSQL │  │  │  │ PostgreSQL │  │
                    │  │   + PVC    │  │  │  │   + PVC    │  │
                    │  └────────────┘  │  │  └────────────┘  │
                    └──────────────────┘  └───────────────────┘

         Internet ──► NGINX Ingress Controller ──► Services ──► Pods
                              │
                        cert-manager
                      (TLS via Let's Encrypt)

                    ┌─────────────────────────────────────┐
                    │           Observability Stack        │
                    │  Prometheus → Grafana (metrics)      │
                    │  Promtail → Loki → Grafana (logs)    │
                    └─────────────────────────────────────┘
```

---

## Services

| Service | Image | Role |
|---|---|---|
| nginx | nginx:alpine | Reverse proxy / load balancer |
| frontend | nginx:alpine | Static web UI |
| api-gateway | nginx:alpine | Main API, routes to services |
| auth-service | nginx:alpine | Authentication & authorization |
| report-service | nginx:alpine | Report generation |
| postgres | postgres:15 | Primary database + PVC |
| redis | redis:7-alpine | Cache & session storage |

---

## Observability Stack

| Component | Role |
|---|---|
| Prometheus | Metrics collection |
| Grafana | Dashboards for metrics and logs |
| Loki | Log aggregation |
| Promtail | Log collector (runs as DaemonSet) |

---

## Tech Stack

| Component | Tool | Purpose |
|---|---|---|
| Local cluster | Minikube | Development environment |
| GitOps | ArgoCD + ApplicationSet | Continuous deployment, multi-env |
| Packaging | Helm | Chart templating |
| Multi-env config | values-dev.yaml / values-prod.yaml | dev / prod overrides |
| Ingress | NGINX Ingress Controller | HTTP routing |
| TLS | cert-manager + Let's Encrypt | Automatic certificates |
| Secrets | Sealed Secrets | Encrypted secrets in Git |
| Monitoring | Prometheus + Grafana | Metrics and dashboards |
| Logging | Loki + Promtail | Log aggregation |
| Autoscaling | HPA + KEDA | Load-based scaling |
| Network | NetworkPolicies | Pod-to-pod traffic control |
| Access control | RBAC | ServiceAccounts and Roles |

---

## Project Structure

```
k8s-platform/
├── apps/                        # ArgoCD manifests
│   └── applicationset.yaml      # Generates all apps for dev + prod
├── charts/                      # Custom Helm charts
│   ├── nginx/
│   ├── frontend/
│   ├── api-gateway/
│   ├── auth-service/
│   ├── report-service/
│   ├── postgres/
│   └── redis/
├── environments/                # Base manifests
│   └── base/
│       └── namespace.yaml
├── monitoring/                  # Observability stack
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── promtail/
├── ingress/                     # Ingress Controller + cert-manager
├── policies/                    # NetworkPolicies + PodSecurityStandards
├── rbac/                        # Roles, ClusterRoles, ServiceAccounts
└── scripts/
    └── bootstrap.sh             # One-command cluster setup
```

---

## Phases

### Phase 1 — Core Workloads (done)
- Namespaces (dev, prod, argocd)
- Helm charts with resource limits
- Liveness and readiness probes

### Phase 2 — GitOps with ArgoCD (done)
- ArgoCD installation and setup
- ApplicationSet for multi-environment deployment (dev + prod)
- Per-environment values (values-dev.yaml / values-prod.yaml)
- Bootstrap script for one-command cluster setup

### Phase 3 — Microservices
- Helm charts: nginx, frontend, api-gateway, auth-service, report-service, postgres, redis
- ConfigMaps and Secrets per service
- PostgreSQL with PersistentVolumeClaim

### Phase 4 — Networking
- NGINX Ingress Controller
- TLS with cert-manager (Let's Encrypt)
- NetworkPolicies (deny-all + explicit allow)

### Phase 5 — Security
- Sealed Secrets (encrypted secrets safe for Git)
- RBAC (least-privilege ServiceAccounts)

### Phase 6 — Observability
- Prometheus stack
- Loki + Promtail (log aggregation)
- Grafana dashboards (metrics + logs)
- Alerting rules

### Phase 7 — Autoscaling & Resilience
- Horizontal Pod Autoscaler (HPA)
- KEDA (event-driven autoscaling)
- Pod Disruption Budgets (PDB)

### Phase 8 — CI/CD Pipeline
- GitHub Actions: build, test, push Docker image
- Automatic image tag update in repo
- ArgoCD picks up change and deploys automatically

---

## Local Setup

### Prerequisites

```bash
# Install tools
brew install minikube kubectl helm argocd

# or on Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Bootstrap local cluster

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

---

## Key Concepts Demonstrated

- **GitOps** — Git as the single source of truth, ArgoCD reconciles cluster state
- **ApplicationSet** — single manifest generates all apps across all environments
- **Immutable infrastructure** — no manual kubectl apply in production
- **Microservices** — multiple focused services instead of a monolith
- **Least privilege** — every workload runs with a minimal ServiceAccount
- **Zero-trust networking** — default deny NetworkPolicies, explicit allow rules
- **Encrypted secrets** — Sealed Secrets allow committing secrets safely to Git
- **Observability** — metrics, logs, and dashboards from day one

---

## Author

Built as a learning and portfolio project to demonstrate production-grade Kubernetes skills.
