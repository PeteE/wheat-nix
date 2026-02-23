# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.wheat.services.niri;
in
{
  options.wheat.services.niri = {
    enable = mkEnableOption "Enable niri window manager";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };
    programs.xwayland = {
      enable = true;
    };
    # programs.niri.settings = {
    #   spawn-at-startup = [
    #     { command = ["xwayland-satellite"]; }  # or handled automatically
    #   ];
    # };
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
      # fuzzel  # app launcher
      kitty
      xwayland-satellite
      thunar
    ];

    environment.variables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
