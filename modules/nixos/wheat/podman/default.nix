# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.podman;
in
{
  options.wheat.services.podman = {
    enable = mkEnableOption "Enable podman";
  };
  config = mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = false;
    virtualisation.podman.dockerSocket.enable = false;
  };
}
