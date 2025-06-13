{ pkgs, lib, ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;

  # TODO REFACTOR

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
}
