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
      extraGroups = ["wheel" "NetworkManager" "kvm"];
    };

    secrets.enable = true;
    wifi.enable = true;
    sudo.enable = true;

    # todo(pete) : replace with VirtNix module
    virtualisation = {
      enable = false;
      libvirtd.enable = false;
      libvirtUri = "qemu+ssh://petee@ripper/system";
    };


    libvirt-vms.enable = true;
    services.podman.enable = true;
    services.clipcat.enable = true;
    remote-builder-client = {
      enable = true;
    };
  };

  hardware.graphics.enable = true;
  console.useXkbConfig = true;
  services.xserver = {
    displayManager.lightdm.enable = false;
    enable = true;
    xkb = {
      options = "caps:escape";
    };
  };

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.uwsm.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      General = {
        DefaultSession = "hyprland-default.desktop";
      };
      Wayland = {
        EnableHiDPI = true;
      };
    };
  };

  # Custom SDDM session files for Hyprland
  environment.etc = {
    "sddm-hyprland-default.desktop" = {
      target = "share/wayland-sessions/hyprland-default.desktop";
      text = ''
        [Desktop Entry]
        Name=Hyprland (Default)
        Comment=Hyprland compositor (managed config)
        Exec=${pkgs.hyprland}/bin/Hyprland --config /home/petee/.config/hypr/hyprland.conf
        Type=Application
        DesktopNames=Hyprland
        X-LightDM-DesktopName=Hyprland (Default)
      '';
    };
    "sddm-hyprland-dev.desktop" = {
      target = "share/wayland-sessions/hyprland-dev.desktop";
      text = ''
        [Desktop Entry]
        Name=Hyprland (Dev)
        Comment=Hyprland compositor (development config)
        Exec=${pkgs.hyprland}/bin/Hyprland --config /home/petee/.config/hypr/hyprland-dev.conf
        Type=Application
        DesktopNames=Hyprland
        X-LightDM-DesktopName=Hyprland (Dev)
      '';
    };
  };
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };
  
  environment.systemPackages = with pkgs; [
    grim-hyprland
    bridge-utils
    cloud-hypervisor
    wheat.rofi-scripts

    # hyrpland
    bluez
    bluez-tools
    blueman
    pavucontrol
    pamixer
    playerctl

    brightnessctl # screen brightness control
    udiskie # manage removable media
    ntfs3g # ntfs support
    exfat # exFAT support
    libinput-gestures # actions touchpad gestures using libinput
    libinput # libinput library
    lm_sensors # system sensors
    pciutils # pci utils

    # misc
    libnotify # Desktop notification library
    envsubst # Environment variable substitution utility
    killall # Process termination utility
    polkit_gnome # authentication agent for privilege escalation
    dbus # inter-process communication daemon
    upower # power management/battery status daemon
    mesa # OpenGL implementation and GPU drivers
    dconf # configuration storage system
    dconf-editor # dconf editor

    xdg-utils # Collection of XDG desktop integration tools
    desktop-file-utils # for updating desktop database
    hicolor-icon-theme # Base fallback icon theme
    kdePackages.ark # kde file archiver
    cava # audio visualizer
    trash-cli # cli to manage trash files
    gawk # awk implementation
    coreutils # coreutils implementation
    hypridle
    xfce.thunar
    hyprpolkitagent
    intel-gpu-tools
  ];
  networking.hostName = "x1";

  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["enp0s31f6" "vm-*"];
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
      Address = ["192.168.100.1/24"];
      DNS = [
        "1.1.1.1"
        "8.8.8.8"
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
  networking.useDHCP = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
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

  powerManagement = {
    enable = true;
    powertop = {
      enable = true;
    };
    cpuFreqGovernor = "performance";
  };

  # Micro VMs
  microvm.vms = {
    # microvm-poc = {
    #   flake = inputs.self;
    # };
  };
  system.stateVersion = "25.11";

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
