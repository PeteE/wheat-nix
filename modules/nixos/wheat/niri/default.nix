# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.services.niri;
in
{
  options.wheat.services.niri = {
    enable = mkEnableOption "Enable niri window manager";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    programs.xwayland = {
      enable = true;
    };
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Wayland = {
          EnableHiDPI = true;
        };
      };
    };
    environment.systemPackages = with pkgs; [
      swaylock
      catppuccin-cursors
      wheat.rofi-scripts
      kitty
      xwayland-satellite
      thunar
      gpu-screen-recorder # screen recording backend for noctalia-shell
      quickshell # provides `qs` CLI for noctalia-shell IPC
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    environment.variables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
