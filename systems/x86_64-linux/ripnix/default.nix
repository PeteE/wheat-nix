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
  imports = [
    (../../../modules/shared/wheat/default.nix)
  ];

  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_24;
  };
  services.tailscale.enable = true;
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

    # SPIRE agent connecting to rpi4 server
    services.spire = {
      enable = true;
      trustDomain = "wheat-dn42.net";
      server.enable = false; # Server runs on rpi4
      agent = {
        enable = true;
        serverAddress = "192.168.1.173"; # rpi4
        insecureBootstrap = true; # Required for initial trust bundle fetch
        x509pop = {
          enable = true;
          privateKeyPath = config.sops.secrets."spire/nodes/ripnix/key".path;
          certificatePath = "/etc/spire/ripnix-cert.pem";
        };
      };
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

  # SPIRE x509pop CA certificate for node attestation
  # This is the same CA cert used across all hosts in the trust domain
  environment.etc."spire/x509pop-ca-bundle.pem" = {
    source = ../x1/spire-x509pop-ca.pem;
    mode = "0644";
  };

  # NixOS-level sops secrets for SPIRE agent
  sops.defaultSopsFile = ../../../modules/home/wheat/secrets/secrets.yaml;
  sops.age.keyFile = "/home/petee/.config/sops/age/keys.txt";
  sops.secrets."spire/nodes/ripnix/key" = {
    mode = "0400";
  };
  sops.secrets."spire/nodes/ripnix/cert" = {
    mode = "0444";
    path = "/etc/spire/ripnix-cert.pem";
  };

  # Ensure SPIRE agent starts after sops secrets are decrypted
  systemd.services.spire-agent.after = [ "sops-nix.service" ];
  systemd.services.spire-agent.wants = [ "sops-nix.service" ];

  # k3s Kubernetes cluster
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=traefik" # We'll use kgateway/Gateway API
      "--write-kubeconfig-mode=644"
      "--flannel-backend=host-gw"
    ];
  };

  # Open firewall for k3s
  networking.firewall.allowedTCPPorts = [ 6443 ]; # k3s API server

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

  nix.settings.trusted-users = [
    "root"
    "petee"
    "pete"
  ];

  # Enable nix-ld to run dynamically linked executables (e.g., playwright, uv-build)
  programs.nix-ld.enable = true;
}
