{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat;
  inherit (lib) mkEnableOption mkOption mkIf;
in {
  options.wheat = {
    plasma = {
      enable = mkEnableOption "Enable";
      remapCapsLockToEscape = mkOption {
        default = true;
        description = "Remap Caps Lock to ESC because we're not neanderthals and can have nice things.";
      };
    };
  };
  config = mkIf cfg.plasma.enable {
    hardware.graphics.enable = true;

    # console.useXkbConfig = true;
    services.xserver = {
      enable = true;
      xkb = {
        options = mkIf cfg.plasma.remapCapsLockToEscape
        "caps:escape";
      };
    };
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard-rs
    ];
  };
}
