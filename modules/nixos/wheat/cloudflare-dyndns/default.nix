# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.cloudflare-dyndns;
in
{
  options.wheat.services.cloudflare-dyndns = {
    enable = mkEnableOption "Cloudflare Dynamic DNS";

    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of domain names to update";
      example = [ "home.example.com" ];
    };

    frequency = mkOption {
      type = types.str;
      default = "*:0/5";
      description = "How often to check/update DNS (systemd timer format)";
      example = "*:0/15"; # every 15 minutes
    };

    ipv4 = mkOption {
      type = types.bool;
      default = true;
      description = "Update IPv4 A records";
    };

    ipv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Update IPv6 AAAA records";
    };

    proxied = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Cloudflare proxy (orange cloud)";
    };
  };

  config = mkIf cfg.enable {
    # Configure sops to decrypt the cloudflare token
    sops.secrets.cloudflare-token = {
      sopsFile = ../../../home/wheat/secrets/secrets.yaml;
      mode = "0400";
    };

    services.cloudflare-dyndns = {
      enable = true;
      inherit (cfg) domains;
      apiTokenFile = config.sops.secrets.cloudflare-token.path;
      inherit (cfg) frequency;
      inherit (cfg) ipv4;
      inherit (cfg) ipv6;
      inherit (cfg) proxied;
    };

    # Ensure secrets are decrypted before service runs
    systemd.services.cloudflare-dyndns = {
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
    };
  };
}
