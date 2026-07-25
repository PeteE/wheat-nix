# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.remote-desktop;
in
{
  options.wheat.remote-desktop = {
    enable = mkEnableOption "remote desktop access to this host";

    backend = mkOption {
      type = types.enum [
        "sunshine"
        "wayvnc"
      ];
      default = "sunshine";
      description = ''
        Which remote-desktop server to run.

        - sunshine: low-latency H.264/HEVC streaming, pair with Moonlight clients.
          Captures via KMS so it works under any Wayland compositor.
        - wayvnc: simple VNC server for wlroots compositors (niri, hyprland, sway).
          Connect with macOS Screen Sharing.app via vnc://host:5900.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open the relevant ports on the system firewall. Leave false if you
        only connect over Tailscale or via an SSH tunnel.
      '';
    };

    wayvnc = {
      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address wayvnc binds to. Use 0.0.0.0 to expose on the LAN.";
      };
      port = mkOption {
        type = types.port;
        default = 5900;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.backend == "sunshine") {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true; # needed for KMS/DRM capture on Wayland
        openFirewall = cfg.openFirewall;
      };
    })

    (mkIf (cfg.enable && cfg.backend == "wayvnc") {
      environment.systemPackages = [ pkgs.wayvnc ];

      # User-level service: wayvnc must run inside the active Wayland session
      # so it can talk to the compositor's wlr-screencopy / virtual-input protocols.
      systemd.user.services.wayvnc = {
        description = "wayvnc - VNC server for wlroots compositors";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.wayvnc}/bin/wayvnc ${cfg.wayvnc.address} ${toString cfg.wayvnc.port}";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.wayvnc.port ];
    })
  ];
}
