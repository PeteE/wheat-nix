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
  ];

  system.stateVersion = "25.11";

  networking.hostName = "x1"; # Define your hostname.
  boot.loader.systemd-boot.enable = true;
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
  networking.wireless = {
    enable = true;
    networks = {
      soma20_5g = {
        pskRaw = "121e447798031c71665a2728c57099b937b3a66b84b0ce21acb6ed7983a823ae";
      };
      AAA_zz = {
        psk = "1god=all";
      };
    };
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    desktopManager.xfce.enable = true;
  };
  services.displayManager = {
    gdm.enable = true;
  };
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    dmidecode
    wget
    curl
    vim
    sops
    tree
  ];
  services.printing.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;

  # my specific customizations
  wheat = {
    user = {
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel" "networkmanager"];
    };
    secrets.enable = true;
  };
}
