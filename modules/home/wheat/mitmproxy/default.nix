# vim: ts=2:sw=t
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.mitmproxy;
  mitm-launcher = pkgs.writeShellScriptBin "mitm-launcher" ''
    #!/usr/bin/env bash
    ${pkgs.mitmproxy}/bin/mitmproxy \
      -m ${cfg.mode} \
      --listen-host ${cfg.listen-host} \
      --listen-port ${toString cfg.listen-port} \
      --set confdir=${config.xdg.configHome}/mitmproxy \
      "$@"
  '';

  mitmweb-launcher = pkgs.writeShellScriptBin "mitmweb-launcher" ''
    #!/usr/bin/env bash
    ${pkgs.mitmproxy}/bin/mitmweb \
      -m ${cfg.mode} \
      --listen-host ${cfg.listen-host} \
      --listen-port ${toString cfg.listen-port} \
      --web-host ${cfg.web-host} \
      --web-port ${toString cfg.web-port} \
      --set confdir=${config.xdg.configHome}/mitmproxy \
      "$@"
  '';

  mitmdump-launcher = pkgs.writeShellScriptBin "mitmdump-launcher" ''
    #!/usr/bin/env bash
    ${pkgs.mitmproxy}/bin/mitmdump \
      -m ${cfg.mode} \
      --listen-port ${toString cfg.listen-port} \
      --set confdir=${config.xdg.configHome}/mitmproxy \
      --flow-detail=2 \
      "$@"
  '';
in
{
  options.wheat.mitmproxy = {
    enable = mkEnableOption "Enable";
    mode = mkOption {
      type = types.str;
      default = "regular";
    };
    listen-host = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    listen-port = mkOption {
      type = types.int;
      default = 8855;
    };
    web-host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Web interface host for mitmweb";
    };
    web-port = mkOption {
      type = types.int;
      default = 8856;
      description = "Web interface port for mitmweb";
    };
  };
  config = mkIf cfg.enable {
    sops.secrets = {
      mitmproxy-dhparam = { };
      mitmproxy-ca = { };
      mitmproxy-ca-cert = { };
    };

    home.activation.mitmproxy-secrets = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/mitmproxy
      cp ${config.sops.secrets.mitmproxy-dhparam.path} ${config.xdg.configHome}/mitmproxy/mitmproxy-dhparam.pem
      cp ${config.sops.secrets.mitmproxy-ca.path} ${config.xdg.configHome}/mitmproxy/mitmproxy-ca.pem  
      cp ${config.sops.secrets.mitmproxy-ca-cert.path} ${config.xdg.configHome}/mitmproxy/mitmproxy-ca-cert.pem
      chmod 600 ${config.xdg.configHome}/mitmproxy/mitmproxy-*.pem
    '';

    home.packages = [
      pkgs.mitmproxy
      mitm-launcher
      mitmweb-launcher
      mitmdump-launcher
    ];
  };
}
