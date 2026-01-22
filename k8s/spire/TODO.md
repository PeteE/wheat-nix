# SPIRE Federation Verification TODO

## 1. Verify Bundle Accessibility

```bash
# K8s cluster can fetch homelab bundle
kubectl exec -n spire deploy/spire-server -- \
  wget -qO- https://spire-bundle.wheat-dn42.net 2>/dev/null | head -c 100

# Homelab can fetch k8s bundle
ssh rpi4 'curl -sk https://spire-bundle-k8s.wheat-dn42.net | head -c 100'

# List federated bundles on k8s
kubectl exec -n spire deploy/spire-server -- \
  spire-server bundle list -socketPath /tmp/spire-server/private/api.sock

# List federated bundles on homelab
ssh rpi4 'sudo spire-server bundle list -socketPath /run/spire/server/private/api.sock'
```

Both should show two trust domains: `wheat-dn42.net` and `k8s.wheat-dn42.net`

## 2. Verify Agents

```bash
# List attested agents on k8s
kubectl exec -n spire deploy/spire-server -- \
  spire-server agent list -socketPath /tmp/spire-server/private/api.sock

# List attested agents on homelab
ssh rpi4 'sudo spire-server agent list -socketPath /run/spire/server/private/api.sock'

# Check agent health on k8s nodes
kubectl exec -n spire -l app.kubernetes.io/name=agent -- \
  spire-agent healthcheck -socketPath /tmp/spire-agent/sockets/spire-agent.sock
```

## 3. Verify Workload Identity

```bash
# Create a test workload registration (k8s)
kubectl exec -n spire deploy/spire-server -- \
  spire-server entry create \
  -socketPath /tmp/spire-server/private/api.sock \
  -spiffeID spiffe://k8s.wheat-dn42.net/test-workload \
  -parentID spiffe://k8s.wheat-dn42.net/spire/agent/k8s_psat/wheat/$(kubectl get nodes -o jsonpath='{.items[0].metadata.uid}') \
  -selector k8s:ns:default \
  -selector k8s:sa:default

# Deploy a test pod and fetch its SVID
kubectl run spire-test --image=ghcr.io/spiffe/spire-agent:latest --restart=Never -- sleep 3600

# Check if workload can get SVID (from inside pod with spire-agent socket mounted)
kubectl exec spire-test -- \
  /opt/spire/bin/spire-agent api fetch x509 -socketPath /spiffe-workload-api/spire-agent.sock
```

## 4. AWS S3 OIDC Test

### Prerequisites
- OIDC provider configured in AWS pointing to `https://oidc-k8s.wheat-dn42.net`
- IAM role with S3 permissions and trust policy for your SPIFFE ID
- Workload entry registered for your test workload

### Test Steps

```bash
# 1. Create workload entry for the test pod
kubectl exec -n spire deploy/spire-server -- \
  spire-server entry create \
  -socketPath /tmp/spire-server/private/api.sock \
  -spiffeID spiffe://k8s.wheat-dn42.net/aws-test \
  -parentID spiffe://k8s.wheat-dn42.net/spire/agent/k8s_psat/wheat/$(kubectl get nodes -o jsonpath='{.items[0].metadata.uid}') \
  -selector k8s:ns:default \
  -selector k8s:pod-label:app:aws-test

# 2. Deploy test pod with AWS CLI and SPIFFE CSI driver
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: aws-test
  labels:
    app: aws-test
spec:
  containers:
  - name: aws
    image: amazon/aws-cli:latest
    command: ["sleep", "3600"]
    env:
    - name: AWS_REGION
      value: "us-west-2"  # your region
    - name: AWS_ROLE_ARN
      value: "arn:aws:iam::ACCOUNT_ID:role/YOUR_ROLE"  # your role ARN
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: "/var/run/secrets/tokens/spiffe-token"
    volumeMounts:
    - name: spiffe-workload-api
      mountPath: /spiffe-workload-api
      readOnly: true
  volumes:
  - name: spiffe-workload-api
    csi:
      driver: csi.spiffe.io
      readOnly: true
EOF

# 3. Get JWT SVID and test AWS
kubectl exec aws-test -- sh -c '
  # Fetch JWT SVID for AWS audience
  /opt/spire/bin/spire-agent api fetch jwt -audience sts.amazonaws.com \
    -socketPath /spiffe-workload-api/spire-agent.sock > /var/run/secrets/tokens/spiffe-token

  # Test S3 access
  aws s3 ls s3://your-test-bucket/
'
```

### Troubleshooting

```bash
# Check OIDC discovery endpoint
curl -s https://oidc-k8s.wheat-dn42.net/.well-known/openid-configuration | jq .

# Check JWKS
curl -s https://oidc-k8s.wheat-dn42.net/keys | jq .

# Verify JWT SVID claims
kubectl exec aws-test -- \
  /opt/spire/bin/spire-agent api fetch jwt -audience sts.amazonaws.com \
    -socketPath /spiffe-workload-api/spire-agent.sock | \
  cut -d. -f2 | base64 -d | jq .
```
