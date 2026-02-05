# k8s-app-gitops

This repository implements GitOps application delivery on top of a Kubernetes cluster provisioned by the companion repo:

**k8s-cluster-automation**

ArgoCD is used as the GitOps controller.

All applications (monitoring, gateway, future workloads) are managed declaratively from this repository.

Once ArgoCD is bootstrapped, no manual kubectl apply is required for applications — Git becomes the single source of truth.

---

## Architecture Overview
```
Oracle VirtualBox VMs  
↓  
Kubernetes (kubeadm + Flannel)  
↓  
ArgoCD  
↓  
k8s-app-gitops Repository  
↓  
Applications
```
---

## Repository Structure

``` 
k8s-app-gitops/
├── README.md
├── apps
│   ├── bootstrap.sh
│   ├── gateway
│   │   ├── gateway.yaml
│   │   ├── grafana-route.yaml
│   │   └── prometheus-route.yaml
│   └── monitoring
│       ├── alertmanager.yaml
│       ├── grafana.yaml
│       ├── namespace.yaml
│       └── prometheus.yaml
└── argocd
    ├── applicationset-crd.yaml
    ├── install.yaml
    └── root-app.yaml
```
---

## Bootstrap from Bastion Host (One Time)
``` 
kubectl create namespace argocd || true  
kubectl apply -n argocd -f argocd/install.yaml
``` 
Install ApplicationSet CRD:
```
kubectl apply -f https://raw.githubusercontent.com/argoproj/applicationset/stable/manifests/install.yaml
```
Create required ConfigMaps:

``` 
kubectl apply -f argocd/bootstrap-configmaps.yaml 
```

Apply root application:
``` 
kubectl apply -f argocd/root-app.yaml
``` 
Verify:
``` 
kubectl get applications -n argocd
``` 
---

## Monitoring Deployment

All monitoring manifests live in:
```
apps/monitoring
```
Deploy by committing:
```
git add apps/monitoring  
git commit -m "update monitoring"  
git push
```
ArgoCD automatically reconciles.

---

## Drift Test
```
kubectl delete ns monitoring  
kubectl get ns -w
```
Namespace will be recreated.

---

## Useful Commands
```
kubectl get applications -n argocd  
kubectl describe application platform-apps -n argocd  
kubectl annotate application platform-apps -n argocd argocd.argoproj.io/refresh=hard
```
---

## ArgoCD UI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Password:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
---

## Design Principles

- Cluster repo builds Kubernetes  
- This repo runs workloads  
- Git is source of truth  
- Automatic reconciliation  
- Self healing  
- Zero manual kubectl for apps

---

Platform Engineering via GitOps.
