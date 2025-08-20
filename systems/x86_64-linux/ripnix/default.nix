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
    sudo.enable = true;
    secrets.enable = true;
    services.podman.enable = true;
    remote-builder.enable = true;

    virtualisation = {
      enable = true;
      libvirtd.enable = false;
      libvirtUri = "qemu+ssh://petee@ripper/system";
    };
    libvirt-vms.enable = true;
  };

  # TODO: move into nixos module (not shared)
  # environment.systemPackages = with pkgs; [
  #   bridge-utils
  # ];

  networking.hostName = "ripnix";

  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["enp1s0" "vm-*"];
    networkConfig = {
      Bridge = "br0";
    };
  };
  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["192.168.1.143/24"];
      Gateway = "192.168.1.33";
      DNS = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      IPv6AcceptRA = false;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  time.timeZone = "America/Chicago";

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "nvme" "uas" "virtio_pci" "virtio_scsi" "virtio_blk" ];
  boot.initrd.kernelModules = [ "amdgpu" "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/36dcd69b-d93a-47ab-aa71-bcaba1a02a59";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  networking.useDHCP = lib.mkDefault false;

  # Micro VMs
  microvm.vms = {
    # microvm-poc = {
    #   flake = inputs.self;
    # };
  };

  nix.settings.trusted-users = [ "root" "petee" "pete" ];

}
