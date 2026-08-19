# vim: ts=2:sw=2:et
{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.keyboard;
in
{
  options.wheat.keyboard = with types; {
    enable = mkEnableOption "custom keyboard remapping";
    remapCapsLockToEscape = mkOption {
      type = bool;
      default = true;
      description = "Remap Caps Lock to Escape";
    };
  };

  config = mkIf cfg.enable {
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToEscape = cfg.remapCapsLockToEscape;
  };
}
