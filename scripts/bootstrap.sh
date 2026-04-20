#!/bin/bash

cd "$(dirname "$0")/.."

minikube start
kubectl apply -f environments/base/namespace.yaml
kubectl apply --server-side -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml
kubectl apply -f apps/applicationset.yaml

echo "Argo is ready use: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "ArgoCD password:"
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""