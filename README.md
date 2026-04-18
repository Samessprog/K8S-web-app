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
                        │         (GitOps controller)          │
                        └──────┬───────────────────┬──────────┘
                               │ syncs             │ syncs
                    ┌──────────▼───────┐  ┌────────▼─────────┐
                    │   Namespace: dev │  │ Namespace: prod   │
                    │                  │  │                   │
                    │  ┌────────────┐  │  │  ┌────────────┐  │
                    │  │  Frontend  │  │  │  │  Frontend  │  │
                    │  │  (nginx)   │  │  │  │  (nginx)   │  │
                    │  └─────┬──────┘  │  │  └─────┬──────┘  │
                    │        │         │  │        │          │
                    │  ┌─────▼──────┐  │  │  ┌─────▼──────┐  │
                    │  │  Backend   │  │  │  │  Backend   │  │
                    │  │   (API)    │  │  │  │   (API)    │  │
                    │  └─────┬──────┘  │  │  └─────┬──────┘  │
                    │        │         │  │        │          │
                    │  ┌─────▼──────┐  │  │  ┌─────▼──────┐  │
                    │  │ PostgreSQL │  │  │  │ PostgreSQL │  │
                    │  │   + PVC    │  │  │  │   + PVC    │  │
                    │  └────────────┘  │  │  └────────────┘  │
                    └──────────────────┘  └───────────────────┘

         Internet ──► NGINX Ingress Controller ──► Services ──► Pods
                              │
                        cert-manager
                      (TLS via Let's Encrypt)
```

---

## Tech Stack

| Component | Tool | Purpose |
|---|---|---|
| Local cluster | kind / k3d | Development environment |
| GitOps | ArgoCD | Continuous deployment |
| Packaging | Helm | Chart templating |
| Multi-env config | Kustomize | dev / staging / prod overlays |
| Ingress | NGINX Ingress Controller | HTTP routing |
| TLS | cert-manager + Let's Encrypt | Automatic certificates |
| Secrets | Sealed Secrets | Encrypted secrets in Git |
| Monitoring | Prometheus + Grafana | Metrics and dashboards |
| Autoscaling | HPA + KEDA | Load-based scaling |
| Network | NetworkPolicies | Pod-to-pod traffic control |
| Access control | RBAC | ServiceAccounts and Roles |

---

## Project Structure

```
k8s-platform/
├── apps/                   # ArgoCD Application manifests
│   ├── dev/
│   └── prod/
├── charts/                 # Custom Helm charts
│   ├── frontend/
│   ├── backend/
│   └── postgresql/
├── environments/           # Kustomize overlays
│   ├── base/               # shared base manifests
│   ├── dev/                # dev overrides
│   ├── staging/            # staging overrides
│   └── prod/               # prod overrides
├── monitoring/             # Prometheus + Grafana stack
│   ├── prometheus/
│   └── grafana/
├── ingress/                # Ingress Controller + cert-manager
├── policies/               # NetworkPolicies + PodSecurityStandards
├── rbac/                   # Roles, ClusterRoles, ServiceAccounts
└── scripts/                # Cluster bootstrap scripts
    └── bootstrap.sh
```

---

## Phases

### Phase 1 — Core Workloads
- Namespaces
- Deployments with resource limits, liveness/readiness probes
- Services (ClusterIP, NodePort)
- ConfigMaps and Secrets

### Phase 2 — Networking
- NGINX Ingress Controller
- TLS with cert-manager (Let's Encrypt)
- NetworkPolicies (deny-all + explicit allow)

### Phase 3 — Configuration Management
- Sealed Secrets (encrypted secrets safe for Git)
- RBAC (least-privilege ServiceAccounts)

### Phase 4 — Helm Packaging
- Write custom Helm charts for each component
- Parameterized values per environment

### Phase 5 — GitOps with ArgoCD
- ArgoCD installation and setup
- ApplicationSets for multi-environment deployment
- Kustomize overlays (dev / staging / prod)

### Phase 6 — Observability
- Prometheus stack (kube-prometheus-stack)
- Custom Grafana dashboards
- Alerting rules

### Phase 7 — Autoscaling & Resilience
- Horizontal Pod Autoscaler (HPA)
- KEDA (event-driven autoscaling)
- Pod Disruption Budgets (PDB)
- Vertical Pod Autoscaler (VPA)

---

## Local Setup

### Prerequisites

```bash
# Install tools
brew install kind kubectl helm kustomize argocd

# or on Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind && mv kind /usr/local/bin/
```

### Bootstrap local cluster

```bash
./scripts/bootstrap.sh
```

---

## Key Concepts Demonstrated

- **GitOps** — Git as the single source of truth, ArgoCD reconciles cluster state
- **Immutable infrastructure** — no manual kubectl apply in production
- **Least privilege** — every workload runs with a minimal ServiceAccount
- **Zero-trust networking** — default deny NetworkPolicies, explicit allow rules
- **Encrypted secrets** — Sealed Secrets allow committing secrets safely to Git
- **Multi-environment** — same Helm chart, different values via Kustomize overlays
- **Observability** — metrics, dashboards, and alerts from day one

---

## Author

Built as a learning and portfolio project to demonstrate production-grade Kubernetes skills.
