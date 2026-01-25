# kgateway

ArgoCD Applications for [kgateway](https://kgateway.dev/) v2.1.2.

## Applications

- `kgateway-crds.yaml` - CRDs (sync-wave -1, installed first)
- `kgateway.yaml` - Control plane

## Prerequisites

Gateway API CRDs must be installed first. See `../gateway-api-crds/`.

## Deploy

```bash
kubectl apply -f kgateway-crds.yaml
kubectl apply -f kgateway.yaml
```
