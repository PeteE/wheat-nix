# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.spire;

  # Generate the OIDC Discovery Provider configuration file
  oidcConfig = pkgs.writeText "oidc-discovery-provider.conf" ''
    log_level = "${cfg.server.oidcDiscovery.logLevel}"

    domains = ["${cfg.server.oidcDiscovery.domain}"]

    server_api {
        address = "unix://${cfg.server.socketPath}"
    }

    health_checks {
        bind_address = "127.0.0.1"
        bind_port = "${toString cfg.server.oidcDiscovery.healthPort}"
        ready_path = "/ready"
        live_path = "/live"
    }

    ${if cfg.server.oidcDiscovery.servingCertFile != null then ''
    serving_cert_file {
        cert_file_path = "${cfg.server.oidcDiscovery.servingCertFile.certPath}"
        key_file_path = "${cfg.server.oidcDiscovery.servingCertFile.keyPath}"
        ${optionalString (cfg.server.oidcDiscovery.servingCertFile.fileSyncInterval != null)
          ''file_sync_interval = "${cfg.server.oidcDiscovery.servingCertFile.fileSyncInterval}"''
        }
        addr = ":${toString cfg.server.oidcDiscovery.bindPort}"
    }
    '' else ''
    insecure_addr = ":${toString cfg.server.oidcDiscovery.bindPort}"
    ''}
  '';

  # Generate the server configuration file
  serverConfig = pkgs.writeText "spire-server.conf" ''
    server {
        bind_address = "${cfg.server.bindAddress}"
        bind_port = "${toString cfg.server.bindPort}"
        trust_domain = "${cfg.trustDomain}"
        data_dir = "/var/lib/spire/server"
        log_level = "${cfg.server.logLevel}"
        ca_ttl = "${cfg.server.caTtl}"
        default_x509_svid_ttl = "${cfg.server.defaultX509SvidTtl}"
        ${optionalString (cfg.server.jwtIssuer != null) ''jwt_issuer = "${cfg.server.jwtIssuer}"''}

        ${optionalString cfg.server.federation.enable ''
        federation {
            bundle_endpoint {
                address = "${cfg.server.federation.bundleEndpoint.address}"
                port = "${toString cfg.server.federation.bundleEndpoint.port}"
            }
        }
        ''}
    }

    plugins {
        DataStore "sql" {
            plugin_data {
                database_type = "sqlite3"
                connection_string = "/var/lib/spire/server/datastore.sqlite3"
            }
        }

        KeyManager "disk" {
            plugin_data {
                keys_path = "/var/lib/spire/server/keys.json"
            }
        }

        NodeAttestor "join_token" {
            plugin_data {}
        }

        ${optionalString cfg.server.x509pop.enable ''
        NodeAttestor "x509pop" {
            plugin_data {
                ca_bundle_path = "${cfg.server.x509pop.caBundlePath}"
            }
        }
        ''}
    }

  '';

  # Generate the agent configuration file
  agentConfig = pkgs.writeText "spire-agent.conf" ''
    agent {
        log_level = "${cfg.agent.logLevel}"
        trust_domain = "${cfg.trustDomain}"
        server_address = "${cfg.agent.serverAddress}"
        server_port = "${toString cfg.agent.serverPort}"
        data_dir = "/var/lib/spire/agent"
        socket_path = "${cfg.agent.socketPath}"
        admin_socket_path = "${cfg.agent.adminSocketPath}"

        ${optionalString cfg.agent.insecureBootstrap ''
        # Insecure bootstrap is NOT appropriate for production use but is ok for
        # simple testing/evaluation purposes.
        insecure_bootstrap = true
        ''}
        ${optionalString (cfg.agent.joinToken != null) ''
        join_token = "${cfg.agent.joinToken}"
        ''}
    }

    plugins {
        KeyManager "disk" {
            plugin_data {
                directory = "/var/lib/spire/agent"
            }
        }

        ${if cfg.agent.x509pop.enable then ''
        NodeAttestor "x509pop" {
            plugin_data {
                private_key_path = "${cfg.agent.x509pop.privateKeyPath}"
                certificate_path = "${cfg.agent.x509pop.certificatePath}"
            }
        }
        '' else ''
        NodeAttestor "join_token" {
            plugin_data {}
        }
        ''}

        WorkloadAttestor "unix" {
            plugin_data {}
        }
    }
  '';
in {
  options.wheat.services.spire = {
    enable = mkEnableOption "SPIRE (SPIFFE Runtime Environment)";

    trustDomain = mkOption {
      type = types.str;
      default = "example.org";
      description = "The SPIFFE trust domain for this SPIRE deployment";
    };

    server = {
      enable = mkEnableOption "SPIRE Server";

      bindAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "Address to bind the SPIRE server to";
      };

      bindPort = mkOption {
        type = types.port;
        default = 8081;
        description = "Port for the SPIRE server to listen on";
      };

      logLevel = mkOption {
        type = types.enum ["DEBUG" "INFO" "WARN" "ERROR"];
        default = "INFO";
        description = "Log level for the SPIRE server";
      };

      caTtl = mkOption {
        type = types.str;
        default = "168h";
        description = "TTL for the server CA";
      };

      defaultX509SvidTtl = mkOption {
        type = types.str;
        default = "48h";
        description = "Default TTL for X.509 SVIDs";
      };

      jwtIssuer = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The JWT issuer URL. This is included in the 'iss' claim of JWT SVIDs.
          Required for OIDC federation with external services like AWS IAM.
          Should match the OIDC discovery provider URL (e.g., "https://oidc.example.com").
        '';
      };

      socketPath = mkOption {
        type = types.str;
        default = "/run/spire/server/private/api.sock";
        description = "Path to the SPIRE server API socket";
      };

      x509pop = {
        enable = mkEnableOption "x509pop node attestation";

        caBundlePath = mkOption {
          type = types.str;
          default = "/var/lib/spire/server/x509pop-ca-bundle.pem";
          description = "Path to the CA bundle for validating node certificates";
        };
      };

      federation = {
        enable = mkEnableOption "SPIRE Federation";

        bundleEndpoint = {
          address = mkOption {
            type = types.str;
            default = "0.0.0.0";
            description = "Address for the federation bundle endpoint to listen on";
          };

          port = mkOption {
            type = types.port;
            default = 8443;
            description = "Port for the federation bundle endpoint";
          };
        };

      };

      oidcDiscovery = {
        enable = mkEnableOption "SPIRE OIDC Discovery Provider";

        domain = mkOption {
          type = types.str;
          description = ''
            The domain where the OIDC Discovery Provider will be accessible.
            This is used in the discovery document and must match the URL
            used to access the provider (e.g., "oidc.example.com").
          '';
        };

        bindPort = mkOption {
          type = types.port;
          default = 8082;
          description = "Port for the OIDC Discovery Provider to listen on";
        };

        healthPort = mkOption {
          type = types.port;
          default = 8083;
          description = "Port for the OIDC Discovery Provider health checks";
        };

        logLevel = mkOption {
          type = types.enum ["debug" "info" "warn" "error"];
          default = "info";
          description = "Log level for the OIDC Discovery Provider";
        };

        servingCertFile = mkOption {
          type = types.nullOr (types.submodule {
            options = {
              certPath = mkOption {
                type = types.str;
                description = "Path to the TLS certificate file";
              };
              keyPath = mkOption {
                type = types.str;
                description = "Path to the TLS private key file";
              };
              fileSyncInterval = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Interval to check for cert/key file changes (e.g., '5m')";
              };
            };
          });
          default = null;
          description = ''
            TLS certificate configuration for the OIDC Discovery Provider.
            If null, the provider will run in insecure (HTTP) mode, suitable
            for use behind a reverse proxy like Caddy that handles TLS.
          '';
        };
      };
    };

    agent = {
      enable = mkEnableOption "SPIRE Agent";

      serverAddress = mkOption {
        type = types.str;
        default = "localhost";
        description = "Address of the SPIRE server to connect to";
      };

      serverPort = mkOption {
        type = types.port;
        default = 8081;
        description = "Port of the SPIRE server to connect to";
      };

      logLevel = mkOption {
        type = types.enum ["DEBUG" "INFO" "WARN" "ERROR"];
        default = "INFO";
        description = "Log level for the SPIRE agent";
      };

      insecureBootstrap = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable insecure bootstrap mode. NOT appropriate for production use
          but useful for testing/evaluation purposes.
        '';
      };

      joinToken = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Join token for agent attestation. Generate with:
          spire-server token generate -spiffeID spiffe://<trust-domain>/<path> \
            -socketPath /run/spire/server/private/api.sock
        '';
      };

      socketPath = mkOption {
        type = types.str;
        default = "/run/spire/agent/public/api.sock";
        description = "Path to the SPIRE agent workload API socket";
      };

      adminSocketPath = mkOption {
        type = types.str;
        default = "/run/spire/agent/private/admin.sock";
        description = "Path to the SPIRE agent admin API socket";
      };

      x509pop = {
        enable = mkEnableOption "x509pop node attestation (requires matching server config)";

        privateKeyPath = mkOption {
          type = types.str;
          default = "/var/lib/spire/agent/node-key.pem";
          description = "Path to the node's private key for x509pop attestation";
        };

        certificatePath = mkOption {
          type = types.str;
          default = "/var/lib/spire/agent/node-cert.pem";
          description = "Path to the node's certificate for x509pop attestation";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spire
      spire-agent
    ];

    # Create necessary directories
    systemd.tmpfiles.rules =
      (optionals cfg.server.enable [
        "d /var/lib/spire/server 0750 root root -"
        "d /run/spire/server/private 0750 root root -"
      ])
      ++ (optionals cfg.agent.enable [
        "d /var/lib/spire/agent 0750 root root -"
        "d /run/spire/agent/public 0755 root root -"
        "d /run/spire/agent/private 0750 root root -"
      ]);

    # SPIRE Server systemd service
    systemd.services.spire-server = mkIf cfg.server.enable {
      description = "SPIRE Server";
      after = ["network-online.target" "local-fs.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.spire}/bin/spire-server run -config ${serverConfig} -socketPath ${cfg.server.socketPath}";
        Restart = "always";
        RestartSec = "5s";

        # Security hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/var/lib/spire/server" "/run/spire/server"];
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    # SPIRE Agent systemd service
    systemd.services.spire-agent = mkIf cfg.agent.enable {
      description = "SPIRE Agent";
      after = ["network-online.target" "local-fs.target"]
        ++ optional cfg.server.enable "spire-server.service";
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.spire}/bin/spire-agent run -config ${agentConfig}";
        Restart = "always";
        RestartSec = "5s";

        # Security hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/var/lib/spire/agent" "/run/spire/agent"];
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    # SPIRE OIDC Discovery Provider systemd service
    systemd.services.spire-oidc-discovery-provider = mkIf cfg.server.oidcDiscovery.enable {
      description = "SPIRE OIDC Discovery Provider";
      after = ["network-online.target" "spire-server.service"];
      requires = ["spire-server.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.spire}/bin/oidc-discovery-provider -config ${oidcConfig}";
        Restart = "always";
        RestartSec = "5s";

        # Security hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        # Needs access to server socket
        ReadWritePaths = ["/run/spire/server"];
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}

