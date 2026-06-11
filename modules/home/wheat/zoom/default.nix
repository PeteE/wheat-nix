# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.zoom;
in
{
  options.wheat.zoom = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zoom-us
    ];
  };
}
