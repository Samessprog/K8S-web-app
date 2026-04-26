# K8S Production-Ready Platform

Portfolio project demonstrating production-grade Kubernetes engineering — full GitOps infrastructure stack built from scratch, chart by chart.

---

## Architecture Overview

```
                       ┌──────────────────────────────────────┐
                       │           GitHub Repository           │
                       │  (single source of truth — GitOps)   │
                       └──────────────────┬───────────────────┘
                                          │ watches
                                          ▼
                       ┌──────────────────────────────────────┐
                       │              ArgoCD                   │
                       │  ApplicationSet — matrix generator    │
                       │  auto-generates apps for dev + prod   │
                       └──────┬────────────────────┬──────────┘
                              │ syncs              │ syncs
                   ┌──────────▼────────┐  ┌────────▼──────────┐
                   │  Namespace: dev   │  │  Namespace: prod   │
                   │                   │  │                    │
                   │  ┌─────────────┐  │  │  ┌─────────────┐  │
                   │  │    NGINX    │  │  │  │    NGINX    │  │
                   │  │  (proxy)    │  │  │  │  (proxy)    │  │
                   │  └──────┬──────┘  │  │  └──────┬──────┘  │
                   │         │         │  │         │          │
                   │  ┌──────▼──────┐  │  │  ┌──────▼──────┐  │
                   │  │  Frontend   │  │  │  │  Frontend   │  │
                   │  └──────┬──────┘  │  │  └──────┬──────┘  │
                   │         │         │  │         │          │
                   │  ┌──────▼──────┐  │  │  ┌──────▼──────┐  │
                   │  │ API Gateway │  │  │  │ API Gateway │  │
                   │  └───┬─────┬───┘  │  │  └───┬─────┬───┘  │
                   │      │     │      │  │      │     │       │
                   │  ┌───▼──┐ ┌▼────┐ │  │  ┌───▼──┐ ┌▼────┐ │
                   │  │ auth │ │ rpt │ │  │  │ auth │ │ rpt │ │
                   │  └───┬──┘ └──┬──┘ │  │  └───┬──┘ └──┬──┘ │
                   │      └───┬───┘    │  │      └───┬───┘     │
                   │  ┌───────▼──────┐ │  │  ┌───────▼──────┐  │
                   │  │  PostgreSQL  │ │  │  │  PostgreSQL  │  │
                   │  │    + PVC     │ │  │  │    + PVC     │  │
                   │  └──────────────┘ │  │  └──────────────┘  │
                   └───────────────────┘  └────────────────────┘

        Internet ──► NGINX Ingress Controller ──► Services ──► Pods
                             │
                       cert-manager
                     (TLS via Let's Encrypt)

                   ┌──────────────────────────────────────┐
                   │          Observability Stack          │
                   │  Prometheus → Grafana  (metrics)      │
                   │  Promtail  → Loki → Grafana  (logs)   │
                   └──────────────────────────────────────┘
```

---

## Services

| Service | Placeholder Image | Role |
|---|---|---|
| nginx | nginx:1.27-alpine | Reverse proxy with CoreDNS resolver |
| frontend | nginx-unprivileged:1.27-alpine | Static React UI (non-root) |
| api-gateway | nginx:1.27-alpine | Main API entrypoint, routes to services |
| auth-service | nginx:1.27-alpine | Authentication & JWT verification |
| report-service | nginx:1.27-alpine | Report generation |
| postgres | postgres:15 | Primary database with PersistentVolumeClaim |
| redis | redis:7-alpine | Cache & session storage |

> All images are placeholders. Production images come from AWS ECR via CI/CD pipeline.

---

## Tech Stack

| Component | Tool | Purpose |
|---|---|---|
| Local cluster | Minikube | Development environment |
| GitOps | ArgoCD + ApplicationSet | Continuous deployment, multi-env |
| Packaging | Helm | Chart templating from scratch |
| Multi-env config | values-dev.yaml / values-prod.yaml | dev / prod overrides |
| Ingress | NGINX Ingress Controller | HTTP routing + TLS termination |
| TLS | cert-manager + Let's Encrypt | Automatic certificates |
| Secrets | Sealed Secrets | Encrypted secrets safe for Git |
| Monitoring | Prometheus + Grafana | Metrics and dashboards |
| Logging | Loki + Promtail | Log aggregation |
| Autoscaling | HPA | CPU-based horizontal scaling |
| Network | NetworkPolicies | Pod-to-pod traffic control |

---

## Project Structure

```
K8S-web-app/
├── apps/
│   └── applicationset.yaml       # ArgoCD matrix generator — all apps x all envs
├── charts/
│   ├── nginx/                    # Reverse proxy (CoreDNS resolver, nginx.conf via ConfigMap)
│   ├── frontend/                 # React UI placeholder (nginx-unprivileged, non-root)
│   ├── api-gateway/              # API entrypoint (ConfigMap env vars, K8S Secrets)
│   ├── auth-service/             # Auth service (JWT Secret, DB Secret)
│   ├── report-service/           # Report service
│   ├── postgres/                 # StatefulSet + PersistentVolumeClaim
│   └── redis/                    # StatefulSet cache
├── environments/
│   └── base/
│       └── namespace.yaml        # dev, prod, argocd namespaces
└── scripts/
    └── bootstrap.sh              # One-command cluster setup from zero
```

Each chart follows the same production pattern:
- `values.yaml` — defaults
- `values-dev.yaml` / `values-prod.yaml` — environment overrides only
- `templates/_helpers.tpl` — reusable name and label functions
- `templates/deployment.yaml` — with securityContext, podSecurityContext, affinity
- `templates/service.yaml` — ClusterIP
- `templates/hpa.yaml` — HPA wrapped in `{{- if .Values.autoscaling.enabled }}`

---

## Key Kubernetes Patterns Demonstrated

- **GitOps** — Git is the single source of truth. No manual `kubectl apply` in production.
- **ApplicationSet matrix generator** — one manifest auto-generates `nginx-dev`, `nginx-prod`, `frontend-dev`, `frontend-prod`, etc.
- **Non-root containers** — all workloads run with `runAsNonRoot: true`, `runAsUser`, `allowPrivilegeEscalation: false`
- **Pod security contexts** — `fsGroup`, `runAsGroup` at pod level for volume ownership
- **CoreDNS resolver in nginx** — defers upstream DNS resolution to request time so nginx starts even when upstreams don't exist yet
- **ConfigMap as env vars** — service URLs injected via `envFrom`, not hardcoded
- **Secret separation** — JWT and DB passwords never in Git, injected via K8S Secrets
- **Pod anti-affinity** — prod workloads spread across nodes with `preferredDuringSchedulingIgnoredDuringExecution`
- **HPA per service** — CPU-based autoscaling with per-env min/max replica config

---

## Phases

### Phase 1 — Core Workloads ✅
- Namespaces (dev, prod, argocd)
- Helm charts written from scratch (no `helm create`)
- Resource requests/limits, liveness and readiness probes
- SecurityContext and podSecurityContext on every workload

### Phase 2 — GitOps with ArgoCD ✅
- ArgoCD installation and UI
- ApplicationSet with matrix generator (apps list x environments list)
- Per-environment Helm values (dev/prod overrides only, not full copies)
- Bootstrap script: `minikube delete && ./scripts/bootstrap.sh` = full working cluster

### Phase 3 — Microservices (in progress)
- [x] nginx — reverse proxy with CoreDNS resolver
- [x] frontend — nginx-unprivileged, non-root, port 8080
- [x] api-gateway — ConfigMap + Secret, envFrom injection
- [x] auth-service — JWT + DB secrets
- [ ] report-service
- [ ] postgres — StatefulSet + PVC
- [ ] redis — StatefulSet

### Phase 4 — Networking
- [ ] NGINX Ingress Controller (replace custom nginx proxy)
- [ ] TLS with cert-manager (Let's Encrypt)
- [ ] NetworkPolicies (default deny, explicit allow)

### Phase 5 — Security
- [ ] Sealed Secrets — encrypted secrets safe to commit to Git
- [ ] RBAC — least-privilege ServiceAccounts per service

### Phase 6 — Observability
- [ ] Prometheus + Grafana (metrics and dashboards)
- [ ] Loki + Promtail (log aggregation)
- [ ] Alerting rules

### Phase 7 — CI/CD Pipeline
- [ ] GitHub Actions: build Docker image, push to ECR
- [ ] Automatic image tag update in Git
- [ ] ArgoCD detects change and deploys automatically

---

## Local Setup

### Prerequisites

```bash
# Required tools
minikube, kubectl, helm, argocd CLI
```

### One-command bootstrap

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

This will:
1. Start minikube
2. Create namespaces (dev, prod, argocd)
3. Install ArgoCD
4. Apply the ApplicationSet
5. Print the ArgoCD admin password

### Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# open https://localhost:8080
# user: admin
```

---

## Author

Built as a learning and portfolio project to demonstrate production-grade Kubernetes engineering from scratch.
