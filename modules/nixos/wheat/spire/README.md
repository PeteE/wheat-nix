# SPIRE NixOS Module

This module provides a NixOS configuration for [SPIRE](https://spiffe.io/spire/) (SPIFFE Runtime Environment), an implementation of the SPIFFE (Secure Production Identity Framework for Everyone) standard for workload identity.

## Overview

SPIRE provides cryptographic identities (SVIDs - SPIFFE Verifiable Identity Documents) to workloads. The system consists of:

- **SPIRE Server**: Issues and manages identities, maintains the trust bundle
- **SPIRE Agent**: Runs on each node, attests workloads and provides SVIDs via a local socket

## Configuration Options

### Basic Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `wheat.services.spire.enable` | bool | false | Enable SPIRE |
| `wheat.services.spire.trustDomain` | string | "example.org" | SPIFFE trust domain |

### Server Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `server.enable` | bool | false | Enable SPIRE Server |
| `server.bindAddress` | string | "0.0.0.0" | Bind address |
| `server.bindPort` | port | 8081 | Server port |
| `server.logLevel` | enum | "INFO" | DEBUG/INFO/WARN/ERROR |
| `server.caTtl` | string | "168h" | CA certificate TTL |
| `server.defaultX509SvidTtl` | string | "48h" | Default X.509 SVID TTL |
| `server.socketPath` | string | "/run/spire/server/private/api.sock" | Server API socket |
| `server.x509pop.enable` | bool | false | Enable x509pop attestation |
| `server.x509pop.caBundlePath` | string | "/var/lib/spire/server/x509pop-ca-bundle.pem" | CA bundle path |

### Agent Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `agent.enable` | bool | false | Enable SPIRE Agent |
| `agent.serverAddress` | string | "localhost" | Server address |
| `agent.serverPort` | port | 8081 | Server port |
| `agent.logLevel` | enum | "INFO" | DEBUG/INFO/WARN/ERROR |
| `agent.insecureBootstrap` | bool | false | Insecure bootstrap (testing only) |
| `agent.joinToken` | string | null | Join token for attestation |
| `agent.socketPath` | string | "/run/spire/agent/public/api.sock" | Workload API socket |
| `agent.adminSocketPath` | string | "/run/spire/agent/private/admin.sock" | Admin API socket |
| `agent.x509pop.enable` | bool | false | Enable x509pop attestation |
| `agent.x509pop.privateKeyPath` | string | "/var/lib/spire/agent/node-key.pem" | Node private key |
| `agent.x509pop.certificatePath` | string | "/var/lib/spire/agent/node-cert.pem" | Node certificate |

## Example Configuration

### Basic Setup with Insecure Bootstrap (Testing)

```nix
wheat.services.spire = {
  enable = true;
  trustDomain = "example.org";
  server.enable = true;
  agent = {
    enable = true;
    insecureBootstrap = true;
  };
};
```

### Production Setup with x509pop Attestation

```nix
wheat.services.spire = {
  enable = true;
  trustDomain = "wheat-dn42.net";
  server = {
    enable = true;
    x509pop = {
      enable = true;
      caBundlePath = "/etc/spire/x509pop-ca-bundle.pem";
    };
  };
  agent = {
    enable = true;
    x509pop = {
      enable = true;
      privateKeyPath = config.sops.secrets."spire/nodes/myhost/key".path;
      certificatePath = "/etc/spire/myhost-cert.pem";
    };
  };
};

# Deploy CA cert
environment.etc."spire/x509pop-ca-bundle.pem" = {
  source = ./spire-x509pop-ca.pem;
  mode = "0644";
};
```

## x509pop Node Attestation

x509pop (X.509 Proof of Possession) attestation uses per-node certificates signed by a CA to prove node identity. This is more secure than join tokens for production use.

### Certificate Hierarchy

```
CA (stored in SOPS)
├── ca-key.pem  (SECRET - never leaves SOPS)
└── ca-cert.pem (public - deployed to servers)
    ├── node1-key.pem  (SECRET - deployed via SOPS to node1)
    │   └── node1-cert.pem (public - deployed to node1)
    ├── node2-key.pem  (SECRET - deployed via SOPS to node2)
    │   └── node2-cert.pem (public - deployed to node2)
    └── ...
```

### Generating Node Certificates

Use the `spire-cert-generator` package to generate node certificates:

```bash
# From within the wheat-nix repo
spire-cert-generator <hostname> [output-dir]

# Examples
spire-cert-generator rpi4
spire-cert-generator x1 /tmp/certs
```

The script:
1. Extracts CA key/cert from SOPS secrets
2. Generates a new EC key pair for the node
3. Creates a certificate with SPIFFE ID in SAN: `spiffe://<trust-domain>/hosts/<hostname>`
4. Outputs YAML ready to paste into SOPS secrets

### SOPS Secrets Structure

```yaml
spire:
  ca_key: |
    -----BEGIN EC PRIVATE KEY-----
    ...
  ca_cert: |
    -----BEGIN CERTIFICATE-----
    ...
  nodes:
    x1:
      key: |
        -----BEGIN EC PRIVATE KEY-----
        ...
      cert: |
        -----BEGIN CERTIFICATE-----
        ...
    rpi4:
      key: |
        ...
```

## Common Commands

### Server Operations

```bash
# Check server health
spire-server healthcheck -socketPath /run/spire/server/private/api.sock

# Generate a join token (for non-x509pop nodes)
spire-server token generate \
  -spiffeID spiffe://wheat-dn42.net/hosts/newnode \
  -socketPath /run/spire/server/private/api.sock

# List registered entries
spire-server entry show -socketPath /run/spire/server/private/api.sock

# Create a workload entry
spire-server entry create \
  -parentID spiffe://wheat-dn42.net/hosts/x1 \
  -spiffeID spiffe://wheat-dn42.net/workloads/myapp \
  -selector unix:uid:1000 \
  -socketPath /run/spire/server/private/api.sock

# List attested agents
spire-server agent list -socketPath /run/spire/server/private/api.sock
```

### Agent Operations

```bash
# Check agent health
spire-agent healthcheck -socketPath /run/spire/agent/public/api.sock

# Fetch X.509 SVID (as a workload)
spire-agent api fetch x509 -socketPath /run/spire/agent/public/api.sock

# Fetch JWT SVID
spire-agent api fetch jwt -audience myservice -socketPath /run/spire/agent/public/api.sock
```

### Service Management

```bash
# Check service status
systemctl status spire-server
systemctl status spire-agent

# View logs
journalctl -u spire-server -f
journalctl -u spire-agent -f

# Restart services
sudo systemctl restart spire-server
sudo systemctl restart spire-agent
```

## Architecture Notes

### Socket Paths

- **Server private socket** (`/run/spire/server/private/api.sock`): Admin operations, registration
- **Agent public socket** (`/run/spire/agent/public/api.sock`): Workload API (any process can query)
- **Agent admin socket** (`/run/spire/agent/private/admin.sock`): Agent admin operations

### Data Directories

- `/var/lib/spire/server/`: Server data (CA keys, datastore)
- `/var/lib/spire/agent/`: Agent data (SVID cache, key material)

### Trust Bundle

The trust bundle contains the public keys that workloads use to verify SVIDs from this trust domain. It's automatically managed by the SPIRE server and distributed to agents.

## References

- [SPIFFE Specification](https://github.com/spiffe/spiffe/blob/main/standards/SPIFFE.md)
- [SPIRE Documentation](https://spiffe.io/docs/latest/spire-about/)
- [x509pop Attestation](https://github.com/spiffe/spire/blob/main/doc/plugin_agent_nodeattestor_x509pop.md)
