# Kanidm Identity Provider

This module configures [Kanidm](https://kanidm.github.io/kanidm/stable/) as a user identity provider for the homelab. Kanidm provides OIDC/OAuth2 authentication for web applications.

## Architecture

```
Internet → Router:443 → rpi4:443 (Caddy L4)
                              ↓
                     SNI: idp.wheat-dn42.net
                              ↓
                     127.0.0.1:8443 (Caddy HTTPS with ACME)
                              ↓
                     127.0.0.1:8445 (Kanidm with self-signed cert)
```

- **Caddy** handles public TLS termination with Let's Encrypt
- **Kanidm** runs on localhost with a self-signed cert (internal only)
- Public URL: `https://idp.wheat-dn42.net`

## Initial Setup / Provisioning

After first deployment, you need to bootstrap admin accounts and create users.

### 1. Recover Admin Accounts

Kanidm has two admin accounts:
- `admin` - Server administration (backups, domain settings)
- `idm_admin` - Identity management (creating users, groups, OAuth2 clients)

Generate passwords for both:

```bash
# On rpi4 as root
sudo kanidmd recover-account -c /etc/kanidm/server.toml admin
sudo kanidmd recover-account -c /etc/kanidm/server.toml idm_admin
```

Save these passwords securely.

### 2. Login via CLI

```bash
# Login as idm_admin for user management
kanidm login -D idm_admin

# Login as admin for server administration
kanidm login -D admin
```

### 3. Create Person Accounts

```bash
# Create a user
kanidm person create <username> "<Display Name>" -D idm_admin

# Generate initial password for the user
sudo kanidmd recover-account -c /etc/kanidm/server.toml <username>
```

### 4. Create Groups

```bash
# Create a group
kanidm group create <group_name> -D idm_admin

# Add members to a group
kanidm group add-members <group_name> <username> -D idm_admin
```

### 5. Add Email to User

```bash
kanidm person update <username> --mail <email@example.com> -D idm_admin
```

## OAuth2 Client Setup

To add SSO to an application:

### 1. Create OAuth2 Client

```bash
# Create a confidential client (for server-side apps)
kanidm system oauth2 create <client_name> "<Display Name>" <landing_url> -D admin

# Example: Grafana
kanidm system oauth2 create grafana "Grafana" https://grafana.wheat-dn42.net -D admin
```

### 2. Configure Scope Mappings

Map groups to OAuth2 scopes:

```bash
# Allow homelab-users to get openid, profile, email scopes
kanidm system oauth2 update-scope-map <client_name> <group_name> openid profile email -D admin

# Example
kanidm system oauth2 update-scope-map grafana homelab-users openid profile email -D admin
```

### 3. Get Client Secret

```bash
kanidm system oauth2 show-basic-secret <client_name> -D admin
```

Use this secret in your application's OIDC configuration.

### 4. Configure the Application

Typical OIDC settings for applications:

| Setting | Value |
|---------|-------|
| Issuer / Authority | `https://idp.wheat-dn42.net/oauth2/openid/<client_name>` |
| Authorization URL | `https://idp.wheat-dn42.net/ui/oauth2` |
| Token URL | `https://idp.wheat-dn42.net/oauth2/token` |
| Userinfo URL | `https://idp.wheat-dn42.net/oauth2/openid/<client_name>/userinfo` |
| JWKS URL | `https://idp.wheat-dn42.net/oauth2/openid/<client_name>/public_key.jwks` |
| Scopes | `openid profile email` |

## Useful CLI Commands

```bash
# List all users
kanidm person list -D idm_admin

# Get user details
kanidm person get <username> -D idm_admin

# List all groups
kanidm group list -D idm_admin

# List OAuth2 clients
kanidm system oauth2 list -D admin

# Get OAuth2 client details
kanidm system oauth2 get <client_name> -D admin

# Delete OAuth2 client
kanidm system oauth2 delete <client_name> -D admin

# Reset OAuth2 client secret
kanidm system oauth2 reset-basic-secret <client_name> -D admin
```

## Web UI

Access the web UI at `https://idp.wheat-dn42.net/ui/`

- Users can manage their profile, passkeys, and credentials
- Admins can view the system status

## Declarative Provisioning (NixOS)

The module supports declarative provisioning via `wheat.services.kanidm.provision`:

```nix
wheat.services.kanidm = {
  enable = true;
  domain = "idp.wheat-dn42.net";
  adminPasswordFile = config.sops.secrets."kanidm/admin-password".path;
  idmAdminPasswordFile = config.sops.secrets."kanidm/idm-admin-password".path;

  provision = {
    enable = true;
    groups = {
      homelab-users = {};
      homelab-admins = { members = [ "petee" ]; };
    };
    persons = {
      petee = {
        displayName = "Pete Erickson";
        mailAddresses = [ "pete.perickson@gmail.com" ];
        groups = [ "homelab-users" "homelab-admins" ];
      };
    };
    oauth2 = {
      grafana = {
        displayName = "Grafana";
        originUrl = "https://grafana.wheat-dn42.net";
        originLanding = "https://grafana.wheat-dn42.net";
        scopeMaps = {
          homelab-users = [ "openid" "profile" "email" ];
        };
      };
    };
  };
};
```

Note: Provisioned users still need their initial password set via `kanidmd recover-account`.

## Comparison with SPIRE

| Aspect | SPIRE | Kanidm |
|--------|-------|--------|
| Purpose | Workload/service identity | User/human identity |
| Who authenticates | Services, pods, VMs | People |
| Credentials issued | X.509 SVIDs, JWT-SVIDs | OIDC tokens, sessions |
| Use case | mTLS between services | SSO for web apps |
| Protocol | SPIFFE/gRPC | OIDC, OAuth2, LDAP |

They are complementary - SPIRE handles "is this service allowed to talk to that service?" while Kanidm handles "is this person allowed to access this app?"

## Troubleshooting

### Check service status
```bash
systemctl status kanidm
journalctl -u kanidm -f
```

### Test connectivity
```bash
curl -sk https://127.0.0.1:8445/status
```

### Reset a user's password
```bash
sudo kanidmd recover-account -c /etc/kanidm/server.toml <username>
```

### Database location
```
/var/lib/kanidm/kanidm.db
```

### TLS certificates (self-signed, internal)
```
/var/lib/kanidm/tls/chain.pem
/var/lib/kanidm/tls/key.pem
```
