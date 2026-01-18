# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.caddy;

  # Build Caddy with the Cloudflare DNS plugin for DNS-01 ACME challenges
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de" ];
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

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
    enable = mkEnableOption "Caddy web server with Cloudflare DNS-01 ACME";

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
    # Configure sops to decrypt the cloudflare token
    sops.secrets.cloudflare-token = {
      sopsFile = ../../../home/wheat/secrets/secrets.yaml;
      mode = "0400";
    };

    # Create an environment file from the raw token using sops templates
    sops.templates."caddy-env".content = ''
      CF_API_TOKEN=${config.sops.placeholder.cloudflare-token}
    '';

    services.caddy = {
      enable = true;
      package = caddyWithCloudflare;

      # Global Caddyfile configuration for Cloudflare DNS-01
      globalConfig = ''
        email ${cfg.email}
        acme_dns cloudflare {env.CF_API_TOKEN}
      '';

      virtualHosts = virtualHostsConfig;
    };

    # Pass the Cloudflare token to Caddy via environment file
    systemd.services.caddy = {
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
      serviceConfig = {
        EnvironmentFile = config.sops.templates."caddy-env".path;
      };
    };

    # Open firewall ports
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
