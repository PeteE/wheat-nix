# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  system,
  ...
}:
with lib; let
  cfg = config.wheat.remote-builder;
in {
  options.wheat.remote-builder = with types; {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    users.users.nixbuilder = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjd2zJEmRiuqMJz2kC4ABIiSVE2HWdRPkZTmcAxp6GS petee@nixos"  # petee
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuGPcJVDVefvFGuQoco+x/rcqJ14vkushdOe9OoHKwG root@ripnix"  # root@ripnix
      ];
    };

    nix.settings.trusted-users = [ "nixbuilder" ];
  };
}
