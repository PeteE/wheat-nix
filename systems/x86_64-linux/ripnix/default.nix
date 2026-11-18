# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  ...
}:
let
  bridgeInterface = "br0";
  lanInterface = "enp1s0";
  vmInterfacePrefix = "vm-*";
  staticIp = "192.168.1.143/24";
  gateway = "192.168.1.33";
  dns = [
    "1.1.1.1"
    "8.8.8.8"
  ];
in
{
  imports = [
    (../../../modules/shared/wheat/default.nix)
  ];

  services.vscode-server = {
    enable = false;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_24;
  };
  wheat.services.tailscale.enable = true;
  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = [
        "wheel"
        "NetworkManager"
        "docker"
      ];
    };
    sudo.enable = true;
    xserver.enable = true;
    coco.enable = true;
    secrets.enable = true;
    fonts.subpixelRgba = "bgr"; # Samsung curved monitor
    services.docker.enable = true;
    remote-builder.enable = true;

    services.niri.enable = true;
    services.clipcat.enable = true;

    virtualisation = {
      enable = true;
      libvirtd.enable = false;
      libvirtUri = "qemu+ssh://petee@ripper/system";
    };
    thermald.enable = true;
    libvirt-vms.enable = true;
    services.nats.enable = true;
    services.clickhouse.enable = false;
    services.suricata = {
      enable = false;
      interface = bridgeInterface;
    };
  };

  networking.hostName = "ripnix";
  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = [
      lanInterface
      vmInterfacePrefix
    ];
    networkConfig = {
      Bridge = bridgeInterface;
    };
  };
  systemd.network.netdevs."${bridgeInterface}" = {
    netdevConfig = {
      Name = "${bridgeInterface}";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "${bridgeInterface}";
    networkConfig = {
      Address = [ staticIp ];
      Gateway = gateway;
      DNS = dns;
      IPv6AcceptRA = false;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  time.timeZone = "America/Chicago";
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "nvme"
    "uas"
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "qxl" ]; # Prevent QXL from conflicting with GPU passthrough
  # QXL is still the boot VGA, so point X at the passed-through AMD GPU explicitly
  services.xserver.deviceSection = ''BusID "PCI:8:0:0"'';
  boot.binfmt.emulatedSystems = [
    "armv6l-linux"
    "aarch64-linux"
  ];

  # Force Wayland compositors to use the AMD GPU (card0) instead of QXL (card1)
  environment.variables = {
    WLR_DRM_DEVICES = "/dev/dri/card0";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
  services.displayManager.sddm.settings.General = {
    DisplayServer = "wayland";
    GreeterEnvironment = "WLR_DRM_DEVICES=/dev/dri/card0,QT_QPA_PLATFORM=wayland";
    ELECTRON_FORCE_DEVICE_SCALE_FACTOR = "1";
  };
  # Tell Weston to use the AMD GPU (card0) for SDDM greeter
  services.displayManager.sddm.wayland.compositorCommand =
    "${pkgs.weston}/bin/weston --shell=kiosk --drm-device=card0";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/36dcd69b-d93a-47ab-aa71-bcaba1a02a59";
    fsType = "ext4";
  };

  swapDevices = [ ];
  # compressed in-RAM swap; gives headroom so big builds don't hard-OOM
  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # amdvlk
      libva
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  networking.useDHCP = lib.mkDefault false;

  environment.systemPackages = with pkgs; [ ];

  # Micro VMs
  microvm.vms = {
    # microvm-poc = {
    #   flake = inputs.self;
    # };
  };

  # limit build parallelism to the 12 pinned vCPUs (default jobs x cores OOMs this 19GiB VM)
  nix.settings.max-jobs = 3;
  nix.settings.cores = 4;
  # make the OOM killer pick build processes before the desktop session
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 500;
  nix.settings.trusted-users = [
    "root"
    "petee"
    "pete"
  ];

  # Enable nix-ld to run dynamically linked executables (e.g., playwright, uv-build)
  programs.nix-ld.enable = true;
}
