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
    modulesPath,
    ...
}:
with lib; let
  cfg = config.wheat.rofi;
in {
  options.wheat.rofi = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
    ];
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";
      package = with pkgs; (rofi.override {
        plugins = [
          rofi-emoji
          rofi-rbw
          rofi-mpd
          rofi-calc
          rofi-systemd
          rofi-file-browser
        ];
      });
    };
    xdg.configFile."rofi/colors.rasi" = {
      source = ./config/colors.rasi;
    };
    xdg.configFile."rofi/font.rasi" = {
      source = ./config/font.rasi;
    };
    xdg.configFile."rofi/runner.rasi" = {
      source = ./config/runner.rasi;
    };
    xdg.configFile."rofi/launcher.rasi" = {
      source = ./config/launcher.rasi;
    };
    xdg.configFile."rofi/clipboard.rasi" = {
      source = ./config/clipboard.rasi;
    };
    xdg.configFile."rofi/rbw.rasi" = {
      source = ./config/rbw.rasi;
    };

  };
}
