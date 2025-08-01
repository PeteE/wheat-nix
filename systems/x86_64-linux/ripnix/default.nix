# vim: ts=2:sw=2:et
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
}: {
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      (../../../modules/shared/wheat/default.nix)
    ];

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel" "NetworkManager"];
    };
    secrets.enable = true;
    services.podman.enable = true;
  };

  networking.hostName = "ripnix";
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "nvme" "uas" "virtio_pci" "virtio_scsi" "virtio_blk" ];
  boot.initrd.kernelModules = [ "amdgpu" "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/36dcd69b-d93a-47ab-aa71-bcaba1a02a59";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  networking.useDHCP = lib.mkDefault true;
}
