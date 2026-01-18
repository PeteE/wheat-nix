# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.caddy;

  # Generate virtualHosts configuration from our simplified format
  virtualHostsConfig = mapAttrs (name: vhost: {
    extraConfig = ''
      reverse_proxy ${vhost.upstream}
    '' + optionalString (vhost.extraConfig != "") ''
      ${vhost.extraConfig}
    '';
  }) cfg.virtualHosts;
in {
  options.wheat.services.caddy = {
    enable = mkEnableOption "Caddy web server with automatic HTTPS";

    email = mkOption {
      type = types.str;
      description = "Email address for ACME certificate notifications";
      example = "admin@example.com";
    };

    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          upstream = mkOption {
            type = types.str;
            description = "Upstream address to reverse proxy to (e.g., localhost:3000)";
            example = "localhost:8080";
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Additional Caddyfile configuration for this host";
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

      # Global Caddyfile configuration
      globalConfig = ''
        email ${cfg.email}
      '';

      virtualHosts = virtualHostsConfig;
    };

    # Open firewall ports for HTTP-01 challenge and HTTPS
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
