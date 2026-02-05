#!/bin/bash
set -e

kubectl create namespace argocd || true
kubectl apply -f argocd/install.yaml

kubectl wait \
--for=condition=available deployment/argocd-server \
-n argocd --timeout=300s

kubectl apply -f argocd/root-app.yaml
