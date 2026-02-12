#!/usr/bin/env bash
# Bootstrap script to create the SOPS age key secret in Kubernetes
# This must be run manually BEFORE deploying the sops-secrets-operator
#
# Usage: ./bootstrap-age-key.sh <age-private-key>
# Example: ./bootstrap-age-key.sh AGE-SECRET-KEY-1XXXXX...

set -euo pipefail

AGE_KEY="${1:-}"

if [[ -z "$AGE_KEY" ]]; then
  echo "Usage: $0 <age-private-key>"
  echo "Example: $0 AGE-SECRET-KEY-1XXXXX..."
  exit 1
fi

# Validate it looks like an age key
if [[ ! "$AGE_KEY" =~ ^AGE-SECRET-KEY- ]]; then
  echo "Error: Key doesn't look like an age secret key (should start with AGE-SECRET-KEY-)"
  exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace sops-secrets-operator --dry-run=client -o yaml | kubectl apply -f -

# Create the secret
kubectl create secret generic sops-age-key \
  --namespace=sops-secrets-operator \
  --from-literal=age-key="$AGE_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Age key secret created successfully in sops-secrets-operator namespace"
