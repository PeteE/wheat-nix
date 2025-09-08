# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.clipcat;
in {
  options.wheat.clipcat = {
    enable = mkEnableOption "enable";
  };
  config = mkIf cfg.enable {
    xdg.configFile."clipcat/clipcatd.toml" = {
      source = ./clipcatd.toml;
    };
  };
}
