#!/usr/bin/env bash
TOKEN=$(spire-agent api fetch jwt -socketPath /run/spire/agent/public/api.sock -audience s3 2>&1 | grep -E "^\s+ey" | tr -d " \t")

CREDS=$(aws sts assume-role-with-web-identity \
--role-arn arn:aws:iam::130132656921:role/test-s3-spiffe \
--role-session-name spiffe-session2 \
--web-identity-token "$TOKEN" \
--query 'Credentials' --output json)

export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.SessionToken')
