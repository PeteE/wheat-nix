#!/usr/bin/env bash
set -euo pipefail

TRUST_DOMAIN="wheat-dn42.net"
SECRETS_FILE="modules/home/wheat/secrets/secrets.yaml"

usage() {
  echo "Generate SPIRE x509pop node certificates"
  echo ""
  echo "Usage:"
  echo "  spire-cert-generator <hostname> [output-dir]"
  echo ""
  echo "Arguments:"
  echo "  hostname    Name of the node (e.g., rpi4, x1)"
  echo "  output-dir  Directory to write certs (default: ./spire-certs)"
  echo ""
  echo "Examples:"
  echo "  spire-cert-generator rpi4"
  echo "  spire-cert-generator x1 /tmp/certs"
  echo ""
  echo "The CA key and cert are extracted from SOPS secrets at:"
  echo "  $SECRETS_FILE"
  exit 1
}

[[ $# -lt 1 ]] && usage
[[ "$1" == "-h" || "$1" == "--help" ]] && usage

hostname="$1"
output_dir="${2:-./spire-certs}"

# Find the repo root (where the secrets file lives)
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
secrets_path="$repo_root/$SECRETS_FILE"

if [[ ! -f "$secrets_path" ]]; then
  echo "Error: Secrets file not found at $secrets_path"
  echo "Make sure you're running from within the wheat-nix repo."
  exit 1
fi

echo "Generating node certificate for: $hostname"
echo "Trust domain: $TRUST_DOMAIN"
echo "SPIFFE ID: spiffe://$TRUST_DOMAIN/hosts/$hostname"
echo "Output directory: $output_dir"
echo

mkdir -p "$output_dir"

# Extract CA key and cert from SOPS
echo "Extracting CA credentials from SOPS..."
ca_key=$(sops decrypt "$secrets_path" --extract '["spire"]["ca_key"]')
ca_cert=$(sops decrypt "$secrets_path" --extract '["spire"]["ca_cert"]')

# Write CA files temporarily
ca_key_file=$(mktemp)
ca_cert_file=$(mktemp)
trap "rm -f $ca_key_file $ca_cert_file" EXIT

echo "$ca_key" > "$ca_key_file"
echo "$ca_cert" > "$ca_cert_file"

# Generate node key
echo "Generating node key..."
openssl ecparam -name prime256v1 -genkey -noout \
  -out "$output_dir/$hostname-key.pem"

# Generate CSR
openssl req -new \
  -key "$output_dir/$hostname-key.pem" \
  -out "$output_dir/$hostname.csr" \
  -subj "/C=US/O=$TRUST_DOMAIN/CN=$hostname"

# Create extensions config for x509pop attestation
ext_file=$(mktemp)
cat > "$ext_file" <<EOF
subjectAltName=URI:spiffe://$TRUST_DOMAIN/hosts/$hostname
keyUsage=critical,digitalSignature
extendedKeyUsage=clientAuth
EOF

# Sign with CA
echo "Signing certificate..."
openssl x509 -req \
  -in "$output_dir/$hostname.csr" \
  -CA "$ca_cert_file" \
  -CAkey "$ca_key_file" \
  -CAcreateserial \
  -out "$output_dir/$hostname-cert.pem" \
  -days 365 \
  -extfile "$ext_file" \
  2>/dev/null

rm -f "$ext_file"

rm -f "$output_dir/$hostname.csr"

echo
echo "=== Node Certificate ==="
openssl x509 -in "$output_dir/$hostname-cert.pem" -noout -subject -issuer
echo
echo "Files created:"
echo "  $output_dir/$hostname-key.pem  (SECRET)"
echo "  $output_dir/$hostname-cert.pem (public)"
echo
echo "=== Add to SOPS secrets.yaml ==="
echo "spire:"
echo "  nodes:"
echo "    $hostname:"
echo "      key: |"
sed 's/^/        /' "$output_dir/$hostname-key.pem"
echo "      cert: |"
sed 's/^/        /' "$output_dir/$hostname-cert.pem"
