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
    ../../../modules/shared/wheat/default.nix
  ];

  wheat = {
    enable = true;
    wifi.enable = true;
    secrets.enable = true;
    user = {
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel" "NetworkManager"];
    };
  };
  networking.hostName = "x1";
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

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  # console.useXkbConfig = true;

  services.xserver = {
    enable = true;
    xkb = {
      options = "caps:escape";
    };
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    dmidecode
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
  system.stateVersion = "25.11";
}
