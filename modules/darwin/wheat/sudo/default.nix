# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  format, # A normalized name for the home target (eg. `home`).
  virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
  host, # The host name for this home.
  config,
  ...
}:
with lib; let
  cfg = config.wheat.sudo;
in {
  options.wheat.sudo = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToEscape = true;
  };
}
