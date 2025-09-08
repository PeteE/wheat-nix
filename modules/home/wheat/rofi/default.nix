# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.ripgrep;
in {
  options.wheat.rofi = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland
      cliphist
    ];
    xdg.configFile."rofi/themes/" = {
      source = "${pkgs.wheat.catppuccin-rofi}/themes/";
    };
    xdg.configFile."rofi/config.rasi" = {
      source = "${pkgs.wheat.catppuccin-rofi}/catppuccin-default.rasi";
    };
  };

}
