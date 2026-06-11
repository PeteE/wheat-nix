# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.kanidm;
in
{
  options.wheat.services.kanidm = {
    enable = mkEnableOption "Kanidm identity management server";

    domain = mkOption {
      type = types.str;
      description = "The domain for Kanidm (used in origin URL)";
      example = "idp.example.com";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to bind the Kanidm server to";
    };

    bindPort = mkOption {
      type = types.port;
      default = 8443;
      description = "Port for the Kanidm server to listen on";
    };

    logLevel = mkOption {
      type = types.enum [
        "trace"
        "debug"
        "info"
        "warn"
        "error"
      ];
      default = "info";
      description = "Log level for Kanidm";
    };

    adminPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing the admin password for Kanidm provisioning.
        Required if provisioning is enabled.
      '';
    };

    idmAdminPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing the idm_admin password for Kanidm provisioning.
        Required if provisioning is enabled.
      '';
    };

    provision = {
      enable = mkEnableOption "declarative provisioning of Kanidm";

      groups = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              members = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "List of members (persons, groups) in this group";
              };
            };
          }
        );
        default = { };
        description = "Groups to provision in Kanidm";
        example = {
          homelab-users = {
            members = [ "pete" ];
          };
          homelab-admins = {
            members = [ "pete" ];
          };
        };
      };

      persons = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              displayName = mkOption {
                type = types.str;
                description = "Display name for the person";
              };
              mailAddresses = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Email addresses for the person";
              };
              groups = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Groups this person belongs to";
              };
            };
          }
        );
        default = { };
        description = "Persons to provision in Kanidm";
      };

      oauth2 = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              displayName = mkOption {
                type = types.str;
                description = "Display name for the OAuth2 client";
              };
              originUrl = mkOption {
                type = types.str;
                description = "Origin URL for the OAuth2 client";
              };
              originLanding = mkOption {
                type = types.str;
                description = "Landing page URL after authentication";
              };
              allowInsecureClientDisablePkce = mkOption {
                type = types.bool;
                default = false;
                description = "Allow clients that don't support PKCE (legacy apps)";
              };
              scopeMaps = mkOption {
                type = types.attrsOf (types.listOf types.str);
                default = { };
                description = "Map Kanidm groups to OAuth2 scopes";
                example = {
                  "homelab-users" = [
                    "openid"
                    "profile"
                    "email"
                  ];
                };
              };
            };
          }
        );
        default = { };
        description = "OAuth2 clients to provision";
      };
    };
  };

  config = mkIf cfg.enable {
    # Add kanidm CLI tools to system path
    environment.systemPackages = [ pkgs.kanidm_1_10 ];

    services.kanidm = {
      enableServer = true;
      enableClient = true;

      package = pkgs.kanidm_1_10.withSecretProvisioning;

      client = {
        enable = true;
        settings = {
          uri = "https://localhost:${toString cfg.bindPort}";
          verify_ca = false;  # Using self-signed cert internally
        };
      };

      server = {
        enable = true;

        settings = {
          inherit (cfg) domain;
          origin = "https://${cfg.domain}";
          bindaddress = "${cfg.bindAddress}:${toString cfg.bindPort}";
          tls_chain = "/var/lib/kanidm/tls/chain.pem";
          tls_key = "/var/lib/kanidm/tls/key.pem";
          log_level = cfg.logLevel;
        };
      };

      provision = mkIf cfg.provision.enable {
        enable = true;
        inherit (cfg) adminPasswordFile;
        inherit (cfg) idmAdminPasswordFile;

        groups = mapAttrs (_name: group: {
          inherit (group) members;
        }) cfg.provision.groups;

        persons = mapAttrs (_name: person: {
          inherit (person) displayName mailAddresses groups;
        }) cfg.provision.persons;

        systems.oauth2 = mapAttrs (_name: client: {
          inherit (client) displayName originUrl originLanding;
          inherit (client) allowInsecureClientDisablePkce scopeMaps;
        }) cfg.provision.oauth2;
      };
    };

    # Generate self-signed TLS cert for Kanidm
    # Caddy handles public TLS, this is just for internal communication
    systemd.services.kanidm-cert-init = {
      description = "Initialize Kanidm TLS certificates";
      wantedBy = [ "kanidm.service" ];
      before = [ "kanidm.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        CERT_DIR="/var/lib/kanidm/tls"
        mkdir -p "$CERT_DIR"

        if [ ! -f "$CERT_DIR/key.pem" ]; then
          echo "Generating self-signed TLS certificate for Kanidm..."
          ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 \
            -keyout "$CERT_DIR/key.pem" \
            -out "$CERT_DIR/chain.pem" \
            -sha256 -days 3650 -nodes \
            -subj "/CN=${cfg.domain}" \
            -addext "subjectAltName=DNS:${cfg.domain},DNS:localhost,IP:127.0.0.1"

          chown -R kanidm:kanidm "$CERT_DIR"
          chmod 600 "$CERT_DIR/key.pem"
          chmod 644 "$CERT_DIR/chain.pem"
        fi
      '';
    };

    # Ensure kanidm service depends on cert init
    systemd.services.kanidm = {
      after = [ "kanidm-cert-init.service" ];
      requires = [ "kanidm-cert-init.service" ];
    };
  };
}
