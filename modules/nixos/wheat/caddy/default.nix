# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.caddy;

  # Build caddy with layer4 plugin for TCP passthrough
  caddyWithL4 = pkgs.caddy.withPlugins {
    plugins = [ "github.com/mholt/caddy-l4@v0.0.0-20260116154418-93f52b6a03ba" ];
    hash = "sha256-bPWjifx2L24g93NHeWoTW2poB52WjbpSuF/NYDdpITk=";
  };

  # Get list of SNI hostnames from virtualHosts
  sniHosts = attrNames cfg.virtualHosts;
  hasVirtualHosts = cfg.virtualHosts != {};
  hasDefaultUpstream = cfg.defaultUpstream != null;

  # Layer4 routes for SNI matching (TLS termination via internal server)
  layer4SniRoutes = map (host: {
    match = [{ tls = { sni = [ host ]; }; }];
    handle = [{
      handler = "proxy";
      upstreams = [{ dial = [ "127.0.0.1:8443" ]; }];
    }];
  }) sniHosts;

  # Default passthrough route (must be last)
  layer4DefaultRoute = {
    handle = [{
      handler = "proxy";
      upstreams = [{ dial = [ "${cfg.defaultUpstream}:443" ]; }];
    }];
  };

  # Build reverse proxy handler for a virtual host
  mkReverseProxyHandler = vhost: {
    handler = "reverse_proxy";
    upstreams = [{ dial = vhost.upstream; }];
  } // optionalAttrs (vhost.upstreamScheme == "https") {
    transport = {
      protocol = "http";
      tls = {} // optionalAttrs vhost.upstreamTlsInsecure {
        insecure_skip_verify = true;
      };
    };
  };

  # HTTP routes for virtual hosts
  virtualHostRoutes = mapAttrsToList (host: vhost: {
    match = [{ host = [ host ]; }];
    handle = [{
      handler = "subroute";
      routes = [{
        handle = [ (mkReverseProxyHandler vhost) ];
      }];
    }];
    terminal = true;
  }) cfg.virtualHosts;

  # Default HTTP route
  defaultHttpRoute = {
    handle = [{
      handler = "reverse_proxy";
      upstreams = [{ dial = "${cfg.defaultUpstream}:80"; }];
    }];
    terminal = true;
  };

  # Full JSON config for Caddy
  caddyConfig = {
    apps =
      # Layer4 for TCP passthrough (only if defaultUpstream is set)
      (optionalAttrs hasDefaultUpstream {
        layer4 = {
          servers = {
            https_passthrough = {
              listen = [ ":443" ];
              routes = layer4SniRoutes ++ [ layer4DefaultRoute ];
            };
          };
        };
      })
      //
      # HTTP server
      {
        http = {
          # Disable automatic HTTPS - we handle TLS via layer4 passthrough
          # and explicit TLS config for virtualHosts
          http_port = 80;
          https_port = 0;  # Disable implicit HTTPS listener
          servers =
            # Internal HTTPS server (only if we have virtualHosts)
            (optionalAttrs hasVirtualHosts {
              internal_https = {
                listen = [ "127.0.0.1:8443" ];
                routes = virtualHostRoutes;
              };
            })
            //
            # Main HTTP server
            {
              http = {
                listen = [ ":80" ];
                routes = virtualHostRoutes
                  ++ (optional hasDefaultUpstream defaultHttpRoute);
              };
            };
        };
      }
      //
      # TLS automation (only if we have virtualHosts)
      (optionalAttrs hasVirtualHosts {
        tls = {
          automation = {
            # Disable on-demand TLS to prevent automatic cert issuance
            on_demand = null;
            policies = [{
              subjects = sniHosts;
              issuers = [{
                module = "acme";
                email = cfg.email;
              }];
            }];
          };
        };
      });
  };
in {
  options.wheat.services.caddy = {
    enable = mkEnableOption "Caddy web server with automatic HTTPS";

    email = mkOption {
      type = types.str;
      description = "Email address for ACME certificate notifications";
      example = "admin@example.com";
    };

    defaultUpstream = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default upstream IP for TCP passthrough of unmatched HTTPS requests";
      example = "192.168.1.245";
    };

    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          upstream = mkOption {
            type = types.str;
            description = "Upstream address to reverse proxy to (e.g., localhost:3000)";
            example = "localhost:8080";
          };
          upstreamScheme = mkOption {
            type = types.enum [ "http" "https" ];
            default = "http";
            description = "Scheme to use when connecting to upstream";
          };
          upstreamTlsInsecure = mkOption {
            type = types.bool;
            default = false;
            description = "Skip TLS verification for HTTPS upstreams (useful for SPIFFE endpoints)";
          };
        };
      });
      default = {};
      description = "Virtual hosts to configure as reverse proxies";
      example = {
        "adguard.example.com" = { upstream = "localhost:3000"; };
      };
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for HTTP (80) and HTTPS (443)";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = caddyWithL4;
    };

    # Write JSON config directly and override systemd to use it without adapter
    environment.etc."caddy/config.json".text = builtins.toJSON caddyConfig;

    systemd.services.caddy = {
      serviceConfig = {
        # Empty string first clears the existing ExecStart before setting new one
        ExecStart = mkForce ["" "${caddyWithL4}/bin/caddy run --config /etc/caddy/config.json"];
        ExecReload = mkForce ["" "${caddyWithL4}/bin/caddy reload --config /etc/caddy/config.json --force"];
      };
    };

    # Open firewall ports
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
