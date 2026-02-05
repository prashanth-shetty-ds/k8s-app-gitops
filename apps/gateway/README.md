# Gateway API + Envoy Gateway (GitOps)

This cluster uses **Kubernetes Gateway API** with **Envoy Gateway** to expose services externally.

**Ingress is NOT used.**

Traffic flow is:

Clients → Envoy Gateway → HTTPRoute → Kubernetes Service → Pods

All routing is managed via **GitOps (ArgoCD)**.

---

## Architecture

```
Browser / curl
↓  
Envoy Gateway (Gateway API) 
↓  
HTTPRoute 
↓  
Service 
↓  
Pods
```
---

## Repository Layout

```
apps/
├── gateway/
│ ├── namespace.yaml
│ ├── gateway-api-crds.yaml
│ ├── gateway.yaml
│ └── envoy-gateway.yaml
│
└── routes/
└── monitoring/
├── grafana-route.yaml
└── prometheus-route.yaml
```

---

# IMPORTANT

Gateway requires TWO CRD layers:

1. Kubernetes Gateway API CRDs
2. Envoy Gateway CRDs

If either is missing, Envoy Gateway will crash.

---

# One-Time Cluster Bootstrap (Manual)

These are infrastructure primitives and are executed ONCE per cluster.

They are NOT GitOps-managed.

---

## 1. Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

kubectl get crds | grep gateway
```

**Expected:**
```
httproutes.gateway.networking.k8s.io
gateways.gateway.networking.k8s.io
gatewayclasses.gateway.networking.k8s.io
```

---
## 2. Install Envoy Gateway CRDs + Controller

``` bash
kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v1.0.2/install.yaml
kubectl get crds | grep envoy
```

**Verify:**
``` bash
kubectl get crds | grep envoy
```

**Expected:**
``` bash
clienttrafficpolicies.gateway.envoyproxy.io
backendtrafficpolicies.gateway.envoyproxy.io
```
---
## 3. Verify Envoy Gateway Pod
```bash
kubectl get pods -n gateway-system
```
**Must show:**
```
envoy-gateway   Running
```

**If not:**
```
kubectl logs -n gateway-system -l app=envoy-gateway
```

GitOps Managed by ArgoCD
========================

Everything below is deployed automatically from this repository.

No kubectl needed after bootstrap.

Gateway Objects
---------------

Located in:

```
apps/gateway/
```
Includes:

*   Namespace    
*   GatewayClass    
*   Gateway    
*   Envoy Gateway deployment
    
---
Routes
------

Located in:

```
apps/routes/ 
```
Each HTTPRoute maps:

FQDN → Service → Pods

### Example Grafana Route
```
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: grafana-route
  namespace: monitoring
spec:
  parentRefs:
  - name: platform-gateway
    namespace: gateway-system
  hostnames:
  - grafana.lab.local
  rules:
  - backendRefs:
    - name: grafana
      port: 3000
```
---
## Accessing Services


Add entries to /etc/hosts (or DNS):

```
<GATEWAY-IP> grafana.lab.local
<GATEWAY-IP> prometheus.lab.local

```

**Get Gateway IP:**

```
kubectl get svc -n gateway-system   
```
Then open:

``` 
http://grafana.lab.local  
http://prometheus.lab.local 
```
---
## Verification Commands

**Check Gateway:**

```
kubectl get gateways -A 
```

**Check Routes:**

```
kubectl get httproutes -A
```

**Check Envoy:**

```
kubectl logs -n gateway-system -l app=envoy-gateway
```

**Check ArgoCD:**

```
kubectl get applications -n argocd
```
---
## GitOps Flow

```
git push     
↓  
ArgoCD sync     
↓  
Gateway + Routes applied     
↓  
Services exposed
```

Design Principles
=================

*   No Ingress    
*   Gateway API standard    
*   Envoy Gateway implementation    
*   ArgoCD GitOps    
*   Routes separated from platform    
*   Declarative networking
    
---
Summary
=======
This setup provides:

*   Kubernetes Gateway API    
*   Envoy Gateway    
*   HTTPRoute-based routing    
*   GitOps automation    
*   Clean separation between platform and applications
    

This is modern Kubernetes networking architecture.







