# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.wheat.services.clipcat;
in
{
  options.wheat.services.clipcat = {
    enable = mkEnableOption "enable";
  };
  config = mkIf cfg.enable {
    services.clipcat.enable = true;
  };
}
