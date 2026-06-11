# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.adguardhome;
in
{
  options.wheat.services.adguardhome = {
    enable = mkEnableOption "AdGuard Home DNS ad blocker";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host address to bind HTTP server to";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port for the web UI";
    };

    dnsPort = mkOption {
      type = types.port;
      default = 53;
      description = "Port for DNS server";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for DNS and web UI";
    };

    mutableSettings = mkOption {
      type = types.bool;
      default = true;
      description = "Allow changes via web UI to persist";
    };

    # Custom DNS rewrites for local services
    dnsRewrites = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            domain = mkOption { type = types.str; };
            answer = mkOption { type = types.str; };
          };
        }
      );
      default = [ ];
      description = "Custom DNS rewrites for local services";
      example = [
        {
          domain = "nas.local";
          answer = "192.168.1.100";
        }
      ];
      # Transform to add enabled = true to each entry
      apply = map (r: r // { enabled = true; });
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      inherit (cfg) host;
      inherit (cfg) port;
      inherit (cfg) openFirewall;
      inherit (cfg) mutableSettings;

      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = cfg.dnsPort;

          # DoH upstream to Cloudflare Family (malware + adult content blocking)
          upstream_dns = [
            "https://1.1.1.3/dns-query"
            "https://1.0.0.3/dns-query"
          ];

          # Fallback DNS (plain DNS, used if DoH fails)
          fallback_dns = [
            "1.1.1.3"
            "1.0.0.3"
          ];

          # Bootstrap DNS (used to resolve DoH hostnames)
          bootstrap_dns = [
            "1.1.1.3"
            "1.0.0.3"
          ];

          # Enable DNSSEC
          enable_dnssec = true;

          # Cache settings
          cache_size = 4194304; # 4MB
          cache_ttl_min = 300;
          cache_ttl_max = 86400;

          # Rate limiting (queries per second per client)
          ratelimit = 0; # disabled for local network
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          safe_search = {
            enabled = false; # disable safe search forcing
          };
          # Custom DNS rewrites for local services
          rewrites = cfg.dnsRewrites;
        };

        # Query logging
        querylog = {
          enabled = true;
          interval = "24h";
          size_memory = 1000;
        };

        # Statistics
        statistics = {
          enabled = true;
          interval = "24h";
        };
      };
    };

    # Open DNS port in firewall (AdGuard Home only opens web UI port)
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.dnsPort
        cfg.port
      ];
      allowedUDPPorts = [ cfg.dnsPort ];
    };
  };
}
