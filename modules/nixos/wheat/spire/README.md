# SPIRE NixOS Module

This module configures SPIRE (SPIFFE Runtime Environment) server and agent on NixOS.

## Configuration

See `default.nix` for all available options under `wheat.services.spire`.

### Basic Example

```nix
wheat.services.spire = {
  enable = true;
  trustDomain = "wheat-dn42.net";

  server = {
    enable = true;
    bindAddress = "0.0.0.0";
    jwtIssuer = "https://oidc.wheat-dn42.net";

    federation = {
      enable = true;
      bundleEndpoint.port = 8444;
    };
  };

  agent = {
    enable = true;
    serverAddress = "localhost";
    insecureBootstrap = true;
  };
};
```

## Federation

### Bundle Endpoint (Serving Your Bundle)

The `federation.bundleEndpoint` config serves your trust bundle to other SPIRE servers.
By default, it uses `https_spiffe` profile (SPIFFE certificate). For web PKI access,
place a reverse proxy (like Caddy) in front that terminates TLS with a Let's Encrypt cert.

### Federating With Other Trust Domains

There are two approaches to fetch bundles from other trust domains:

#### Option 1: Config File (`federates_with`) - NOT RECOMMENDED

The module supports `trustedDomains` which generates `federates_with` blocks:

```nix
federation.trustedDomains = [{
  trustDomain = "k8s.wheat-dn42.net";
  bundleEndpointUrl = "https://spire-bundle-k8s.wheat-dn42.net";
  bundleEndpointProfile = "https_web";
}];
```

**Note:** As of SPIRE 1.13, the `federates_with` config validates but may not trigger
automatic bundle fetching. This appears to be a behavioral change or bug.

#### Option 2: Federation API - RECOMMENDED

Use the SPIRE CLI to create federation relationships via the datastore:

```bash
# Create federation relationship (auto-refreshes)
sudo spire-server federation create \
  -socketPath /run/spire/server/private/api.sock \
  -bundleEndpointURL https://spire-bundle-k8s.wheat-dn42.net \
  -bundleEndpointProfile https_web \
  -trustDomain k8s.wheat-dn42.net

# List relationships
sudo spire-server federation list \
  -socketPath /run/spire/server/private/api.sock

# Show details
sudo spire-server federation show \
  -trustDomain k8s.wheat-dn42.net \
  -socketPath /run/spire/server/private/api.sock

# Manually refresh bundle
sudo spire-server federation refresh \
  -trustDomain k8s.wheat-dn42.net \
  -socketPath /run/spire/server/private/api.sock

# Delete relationship
sudo spire-server federation delete \
  -trustDomain k8s.wheat-dn42.net \
  -socketPath /run/spire/server/private/api.sock
```

**Advantages:**
- Stored in datastore (persists across restarts)
- Auto-refreshes bundles reliably
- Can be managed dynamically without restarting SPIRE

**Disadvantage:**
- Must run command after SPIRE server starts (not fully declarative)

### Current Federation Setup (wheat-dn42.net)

- **Homelab** (`wheat-dn42.net` on rpi4):
  - Bundle served at: `https://spire-bundle.wheat-dn42.net`
  - Federation with k8s created via: `spire-server federation create`

- **K8s cluster** (`k8s.wheat-dn42.net`):
  - Bundle served at: `https://spire-bundle-k8s.wheat-dn42.net`
  - Federation managed by SPIRE Controller Manager via `ClusterFederatedTrustDomain` CRD

## Socket Paths

- Server API: `/run/spire/server/private/api.sock`
- Agent workload API: `/run/spire/agent/public/api.sock`
- Agent admin API: `/run/spire/agent/private/admin.sock`
