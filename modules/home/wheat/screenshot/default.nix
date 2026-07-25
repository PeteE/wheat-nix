# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  options,
  ...
}:
with lib;
let
  cfg = config.wheat.screenshot;
in
{
  options.wheat.screenshot = {
    enable = mkEnableOption "Enable Wayland screenshot tools (grim + slurp + satty)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard
    ];

    xdg.configFile."satty/config.toml".text = ''
      [general]
      fullscreen = true
      output-filename = "~/screens/screen-%Y%m%d%H%M%S.png"
      copy-command = "wl-copy"
      early-exit = true
    '';
  };
}
