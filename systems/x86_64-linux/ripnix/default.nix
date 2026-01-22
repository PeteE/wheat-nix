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
  imports =
    [
      (../../../modules/shared/wheat/default.nix)
    ];

  services.vscode-server = { 
    enable = true;
    enableFHS = true;
  };
  services.tailscale.enable = true;
  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel" "NetworkManager"];
    };

    services.spire = {
      enable = true;
      trustDomain = "wheat-dn42.net";
      server = {
        enable = true;
        x509pop = {
          enable = true;
          caBundlePath = "/etc/spire/x509pop-ca-bundle.pem";
        };
      };
      agent = {
        enable = false;  # Server-only node for now
      };
    };
    sudo.enable = true;
    xserver.enable = true;
    secrets.enable = true;
    fonts.subpixelRgba = "bgr";  # Samsung curved monitor
    services.podman.enable = true;
    remote-builder.enable = true;

    services.hyprland.enable = false;
    services.niri.enable = true;

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

  # SPIRE x509pop CA certificate for node attestation
  # This is the same CA cert used across all hosts in the trust domain
  environment.etc."spire/x509pop-ca-bundle.pem" = {
    source = ../x1/spire-x509pop-ca.pem;
    mode = "0644";
  };

  networking.hostName = "ripnix";
  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = [lanInterface vmInterfacePrefix];
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
      Address = [staticIp];
      Gateway = gateway;
      DNS = dns;
      IPv6AcceptRA = false;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  time.timeZone = "America/Chicago";

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "nvme" "uas" "virtio_pci" "virtio_scsi" "virtio_blk" ];
  boot.initrd.kernelModules = [ "amdgpu" "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "qxl" ];  # Prevent QXL from conflicting with GPU passthrough

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
  services.displayManager.sddm.wayland.compositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk --drm-device=card0";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/36dcd69b-d93a-47ab-aa71-bcaba1a02a59";
      fsType = "ext4";
    };

  swapDevices = [ ];

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


  # Micro VMs
  microvm.vms = {
    # microvm-poc = {
    #   flake = inputs.self;
    # };
  };

  nix.settings.trusted-users = [ "root" "petee" "pete" ];
  nix.settings.substituters = [ "https://nix-cache-dev.corp.tooling.opaque-int.com/opaque" ];
  nix.settings.trusted-public-keys = [ "opaque:od+Hipzy1dL0ZZBg24QiYP2QgEXVPVSQfDVSBxDBNWU=" ];

  # Enable nix-ld to run dynamically linked executables (e.g., playwright, uv-build)
  programs.nix-ld.enable = true;
}
