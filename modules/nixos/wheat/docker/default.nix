# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.docker;
in
{
  options.wheat.services.docker = {
    enable = mkEnableOption "Enable docker";
  };
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-buildx
    ];
  };
}
