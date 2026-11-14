{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (../../../modules/shared/wheat/default.nix)
    ./disko.nix
  ];

  # Lenovo ThinkCentre Tiny (i5-6500T, 16GB, Micron 1100 SATA SSD), UEFI
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "k8s-worker-300";
  networking.useDHCP = lib.mkDefault true;
  # flannel vxlan (8472/udp), kubelet (10250), metallb memberlist (7946) and
  # NodePorts all need to be reachable; same as the other nodes
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = "x86_64-linux";

  time.timeZone = "America/Chicago";

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$ysACyCk2sIkE4gjt8JfgK0$ZS1H7jaFrrMbZj1QGX2xm/omN8rGAwl6cAcZbfKQykC";
      extraGroups = [ "wheel" ];
    };
    sudo.enable = true;
    services.k3s-agent.enable = true;
  };
}
