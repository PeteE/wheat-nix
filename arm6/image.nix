# Heavily based on https://gist.github.com/sorki/548de08f621b066c94f0c36a7a78cc41#file-configuration-nix-L9
{ config, lib, pkgs, ... }:

{
  imports = [
    <nixos-unstable/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix>
  ];

  # Keep it ready for `dd`ing it on the SD card
  sdImage = {
    compressImage = false;
  };

  nixpkgs = {
    crossSystem = {
      system = "armv6l-linux";
      platform = lib.systems.platforms.raspberrypi;
    };

    # overlays = [
    #   (self: super: {
    #     mailutils = null; # Does not cross-compile. Missing binary breaks sendmail functionality of smartd
    #   })
    # ];
  };
  # nixpkgs.hostPlatform.system = "armv6l-linux";
  # nixpkgs.buildPlatform.system = "x86_64-linux";

  documentation.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  system.stateVersion = "24.05";
  ## Combats the default setting of wpa_supplicant not starting on installation devices
  ## https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/installation-device.nix#L74
  # systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 49 [ "multi-user.target" ];
}
