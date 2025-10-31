# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib; let
  cfg = config.wheat.services.hyprland;
in
{
  options.wheat.services.hyprland = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      # Install the packages from nixpkgs
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      # Whether to enable XWayland
      xwayland.enable = true;
      withUWSM = true;
    };
    programs.uwsm.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        General = {
          DefaultSession = "hyprland-default.desktop";
        };
        Wayland = {
          EnableHiDPI = true;
        };
      };
    };

    # Custom SDDM session files for Hyprland
    environment.etc = {
      "sddm-hyprland-default.desktop" = {
        target = "share/wayland-sessions/hyprland-default.desktop";
        text = ''
          [Desktop Entry]
          Name=Hyprland (Default)
          Comment=Hyprland compositor (managed config)
          Exec=${pkgs.hyprland}/bin/Hyprland --config /home/petee/.config/hypr/hyprland.conf
          Type=Application
          DesktopNames=Hyprland
          X-LightDM-DesktopName=Hyprland (Default)
        '';
      };
    };
    environment.variables = {
      NIXOS_OZONE_WL = "1";
    };
    environment.systemPackages = with pkgs; [
      bridge-utils
      cloud-hypervisor
      wheat.rofi-scripts

      catppuccin-cursors
      ntfs3g
      exfat
      libinput # libinput library
      lm_sensors # system sensors
      pciutils # pci utils

      grim-hyprland
      libnotify
      grimblast
      slurp
      bluez
      bluez-tools
      blueman
      pavucontrol
      pamixer
      playerctl
      libinput-gestures # actions touchpad gestures using libinput
      brightnessctl # screen brightness control
      lm_sensors # system sensors
      pciutils # pci utils

      # misc
      libnotify # Desktop notification library
      envsubst # Environment variable substitution utility
      killall # Process termination utility
      polkit_gnome # authentication agent for privilege escalation
      dbus # inter-process communication daemon
      upower # power management/battery status daemon
      mesa # OpenGL implementation and GPU drivers
      dconf # configuration storage system
      dconf-editor # dconf editor

      xdg-utils # Collection of XDG desktop integration tools
      desktop-file-utils # for updating desktop database
      hicolor-icon-theme # Base fallback icon theme
      kdePackages.ark # kde file archiver
      cava # audio visualizer
      trash-cli # cli to manage trash files
      gawk # awk implementation
      coreutils # coreutils implementation
      hypridle
      xfce.thunar
      hyprpolkitagent
      hyprlock
    ];
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
