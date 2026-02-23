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
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (../../../modules/shared/wheat/default.nix)
  ];

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = [
        "wheel"
        "NetworkManager"
        "kvm"
        "dialout"
        "disk"
      ];
    };

    # SPIRE agent connecting to rpi4 server
    services.spire = {
      enable = true;
      trustDomain = "wheat-dn42.net";
      server.enable = false;  # Server runs on rpi4
      agent = {
        enable = true;
        serverAddress = "192.168.1.173";  # rpi4
        insecureBootstrap = true;  # Required for initial trust bundle fetch
        x509pop = {
          enable = true;
          privateKeyPath = config.sops.secrets."spire/nodes/x1/key".path;
          certificatePath = "/etc/spire/x1-cert.pem";
        };
      };
    };

    xserver.enable = true;
    secrets.enable = true;
    wifi.enable = true;
    sudo.enable = true;
    coco.enable = true;

    # # todo(pete) : replace with VirtNix module
    # virtualisation = {
    #   enable = false;
    #   libvirtd.enable = false;
    #   libvirtUri = "qemu+ssh://petee@ripper/system";
    # };
    thermald.enable = true;
    libvirt-vms.enable = true;
    services.clipcat.enable = true;
    remote-builder-client = {
      enable = true;
    };
    services.hyprland.enable = true;
    services.niri.enable = true;
  };

  # SPIRE x509pop certificates for node attestation
  environment.etc."spire/x509pop-ca-bundle.pem" = {
    source = ./spire-x509pop-ca.pem;
    mode = "0644";
  };

  # NixOS-level sops secrets for SPIRE agent
  sops.defaultSopsFile = ../../../modules/home/wheat/secrets/secrets.yaml;
  sops.age.keyFile = "/home/petee/.config/sops/age/keys.txt";
  sops.secrets."spire/nodes/x1/key" = {
    mode = "0400";  # Only root can read
  };
  sops.secrets."spire/nodes/x1/cert" = {
    mode = "0444";
    path = "/etc/spire/x1-cert.pem";  # Deploy cert to expected location
  };

  # Ensure SPIRE agent starts after sops secrets are decrypted
  systemd.services.spire-agent.after = [ "sops-nix.service" ];
  systemd.services.spire-agent.wants = [ "sops-nix.service" ];

  hardware.graphics.enable = true;
  console.useXkbConfig = true;
  services.upower.enable = true;
  services.xserver = {
    displayManager.lightdm.enable = false;
    enable = true;
    xkb = {
      options = "caps:escape";
    };
  };
  environment.systemPackages = with pkgs; [
    wheat.spire-cert-generator
    wireshark
    rpi-imager
    intel-gpu-tools
    gthumb
    shotwell
    dvdplusrwtools
    dvdauthor
    vlc
    cdrkit
    minicom
    wireshark
    cloud-hypervisor
    ntfs3g
    exfat
    libinput
    libnotify
    slurp
    bluez
    bluez-tools
    blueman
    pavucontrol
    pamixer
    playerctl
    libinput-gestures # actions touchpad gestures using libinput
    brightnessctl # screen brightness control
    lm_sensors # system sensors
    pciutils # pci utils

    # misc
    libnotify # Desktop notification library
    envsubst # Environment variable substitution utility
    killall # Process termination utility
    dbus # inter-process communication daemon
    upower # power management/battery status daemon
    mesa # OpenGL implementation and GPU drivers
    dconf # configuration storage system
    dconf-editor # dconf editor

    xdg-utils # Collection of XDG desktop integration tools
    desktop-file-utils # for updating desktop database
    hicolor-icon-theme # Base fallback icon theme
    thunar
  ];
  networking.useDHCP = true;
  networking.useNetworkd = true;
  networking.hostName = "x1";
  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["enp0s31f6" "vm-*"];
    networkConfig = {
      Bridge = "br0";
    };
  };

  # bridge device for VMs
  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["192.168.100.1/24"];
      DNS = [
        "192.168.1.173"  # rpi4 AdGuard Home
        "1.1.1.1"        # fallback
      ];
      IPv6AcceptRA = false;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "wlp2s0";
    internalInterfaces = [ "br0" ];
  };

  time.timeZone = "America/Chicago";
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
      editor = true;
      configurationLimit = 10;
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0c0f9ee0-40ed-4fdd-adab-844ca3e9b712";
    fsType = "ext4";
  };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/914C-75B5";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/6bacfc99-1805-42fb-9797-3593255c1dff";
    }
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  services.tailscale.enable = true;
  services.printing.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.blueman.enable = true;
  services.libinput.enable = true;

  # Power management
  powerManagement = {
    enable = true;
    powertop = {
      enable = true;
    };
    # cpuFreqGovernor = "performance";
  };
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      STOP_CHARGE_THRESH_BAT0 = 95;
    };
  };

  programs.adb.enable = true;
  programs.uwsm.enable = true;
  system.stateVersion = "25.11";
}
