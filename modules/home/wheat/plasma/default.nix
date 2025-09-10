{
    lib,
    pkgs,
    inputs,
    namespace,
    target,
    format,
    virtual,
    host,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.plasma;
in {
  options = {
    wheat.plasma = with types; {
      enable = mkEnableOption "Enable";
    };
  };

  config = mkIf cfg.enable {
    # music player
    # programs.elisa.enable = true;

    # make it pretty
    home.packages = with pkgs; [
      catppuccin-qt5ct
      catppuccin
      catppuccin-kde
      catppuccin-sddm
      catppuccin-sddm-corners
      catppuccin-grub
      catppuccin-cursors
      # kdePackages.kconfig
      # kconfig
    ];

    programs.plasma = {
      enable = true;
      workspace = {
        # clickItemTo = "open";
        # lookAndFeel = "org.kde.breezedark.desktop";
        # cursor = {
        #   theme = "Bibata-Modern-Ice";
        #   size = 32;
        # };
        # iconTheme = "Papirus-Dark";
        # wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
      };

      hotkeys = {
        commands = {
          "launch-konsole" = {
            name = "Launch Konsole";
            key = "Meta+Alt+Z";
            command = "konsole";
          };
          # "rofi-clipboard" = {
          #   name = "Rofi Clipboard";
          #   key = "Meta+Shift+S";
          #   command = "/nix/store/v347qi0b6yzx63gkc2f0p3zxqnfxpn9k-rofi-scripts-0.1.0/bin/rofi-clipboard";
          # };
        };
      };
      configFile = { };
      dataFile = { };
    };
  };
}
