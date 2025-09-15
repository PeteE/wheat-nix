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
    # home.packages = with pkgs; [
    #   catppuccin-qt5ct
    #   catppuccin
    #   catppuccin-kde
    #   catppuccin-sddm
    #   catppuccin-sddm-corners
    #   catppuccin-grub
    #   catppuccin-cursors
    #   # kdePackages.kconfig
    #   # kconfig
    # ];

    programs.plasma = {
      enable = false;
      hotkeys = {
        commands = {
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
