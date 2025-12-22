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
  ];
  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.initrd.allowMissingModules = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = false;
  networking.hostName = "rpi4";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "America/Chicago";

  wheat = {
    enable = true;
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
  nix.settings.trusted-users = [ "root" "petee" "pete" ];
  # nix.settings.substituters = [ "https://nix-cache-dev.corp.tooling.opaque-int.com/opaque" ];
}
