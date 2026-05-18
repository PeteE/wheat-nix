{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (../../../modules/shared/wheat/default.nix)
    <nixpks/modules/installer/cd-dvd/sd-image-raspberrypi.nix>
  ];

  sdImage = {
    compressImage = false;
  };
  nixpkgs.crossSystem = {
    system = "armv6l-linux";
    platform = lib.systems.platforms.raspberrypi;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi1;
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.initrd.allowMissingModules = true;

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = false;
  networking.hostName = "rpiw";
  nixpkgs.hostPlatform = lib.mkDefault "armv6l-linux";

  time.timeZone = "America/Chicago";

  wheat = {
    enable = false;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$ysACyCk2sIkE4gjt8JfgK0$ZS1H7jaFrrMbZj1QGX2xm/omN8rGAwl6cAcZbfKQykC";
      extraGroups = [
        "wheel"
        "NetworkManager"
        "dialout"
      ];
    };
    sudo.enable = true;
    secrets.enable = true;
    wifi.enable = true;
  };
  system.stateVersion = "25.11";
  nix.settings.trusted-users = [
    "root"
    "petee"
    "pete"
  ];
  # nix.settings.substituters = [ "https://nix-cache-dev.corp.tooling.opaque-int.com/opaque" ];
}
