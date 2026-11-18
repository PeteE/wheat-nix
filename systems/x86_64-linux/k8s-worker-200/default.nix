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

  # Supermicro X8DTL, 2x Xeon E5620, legacy BIOS only (ex "hv" hypervisor)
  boot.initrd.availableKernelModules = [
    "mptsas" # LSI SAS1068E: both SSDs
    "ata_piix"
    "uhci_hcd"
    "ehci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.grub = {
    enable = true;
    # disko adds the OS disk (EF02 partition) to grub.devices
    configurationLimit = 10;
  };
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "k8s-worker-200";
  time.timeZone = "America/Chicago";

  # Static LAN address on onboard NIC 1 (pinned by MAC); NIC 2 unused
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    links."10-lan0" = {
      matchConfig.PermanentMACAddress = "00:25:90:02:fb:a6";
      linkConfig.Name = "lan0";
    };
    networks."40-lan0" = {
      matchConfig.Name = "lan0";
      address = [ "192.168.1.50/24" ];
      routes = [ { Gateway = "192.168.1.33"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
  # flannel vxlan (8472/udp), kubelet (10250), metallb memberlist (7946) and
  # NodePorts all need to be reachable; same as the other nodes
  networking.firewall.enable = false;

  # k3s state lives on the data SSD; never let it start on the root disk
  systemd.services.k3s.unitConfig.RequiresMountsFor = [ "/var/lib/rancher" ];

  services.tailscale.enable = true;

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

  environment.systemPackages = with pkgs; [
    smartmontools
  ];
}
