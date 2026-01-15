# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.spire;
in {
  options.wheat.services.spire = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spire
      spire-agent
      spire-server
    ];
  };
}

