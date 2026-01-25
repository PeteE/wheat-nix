# Istio

ArgoCD Applications for Istio v1.24.2.

## Applications

- `istio-base.yaml` - CRDs and base resources (sync-wave -2)
- `istiod.yaml` - Control plane (sync-wave -1)

## Deploy

```bash
kubectl apply -f istio-base.yaml
kubectl apply -f istiod.yaml
```

## Verify

```bash
kubectl get pods -n istio-system
istioctl version
```
