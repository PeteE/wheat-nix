# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.tailscale-serve;
  tailscale = config.services.tailscale.package;

  serveCommands = concatStringsSep "\n" (
    mapAttrsToList (
      name: svc:
      "echo 'serve ${name}: https:${toString svc.httpsPort}${svc.path} -> ${svc.target}'\n"
      + "tailscale serve --bg --https=${toString svc.httpsPort} --set-path ${escapeShellArg svc.path} ${escapeShellArg svc.target}"
    ) cfg.services
  );
in
{
  options.wheat.services.tailscale-serve = {
    enable = mkEnableOption "declarative tailscale serve (tailnet-only HTTPS reverse proxy)";

    services = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            httpsPort = mkOption {
              type = types.port;
              description = ''
                HTTPS port exposed on the node's tailnet address. Avoid 443 if
                another service (e.g. Caddy) already listens on all interfaces,
                since tailscale serve intercepts that port on the tailnet IP.
              '';
              example = 10443;
            };
            path = mkOption {
              type = types.str;
              default = "/";
              description = "URL path prefix to mount the target under";
            };
            target = mkOption {
              type = types.str;
              description = "Local backend to proxy to";
              example = "http://127.0.0.1:8080";
            };
          };
        }
      );
      default = { };
      description = ''
        Services to publish via `tailscale serve` (tailnet only, never Funnel).
        The serve config is reset on each start, so any manually added serve
        entries on this node will be removed.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "wheat.services.tailscale-serve requires services.tailscale.enable";
      }
    ];

    systemd.services.tailscale-serve = {
      description = "Configure tailscale serve";
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        tailscale
        pkgs.jq
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${tailscale}/bin/tailscale serve reset";
      };

      # Wait for tailscaled to be logged in and running before configuring serve
      script = ''
        for _ in $(seq 1 60); do
          if tailscale status --json | jq -e '.BackendState == "Running"' >/dev/null; then
            break
          fi
          sleep 1
        done
        tailscale status --json | jq -e '.BackendState == "Running"' >/dev/null

        tailscale serve reset
        ${serveCommands}
        tailscale serve status
      '';
    };
  };
}
