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

  # Supermicro X8DTL, 2x Xeon E5620, legacy BIOS only
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

  networking.hostName = "hv";
  time.timeZone = "America/Chicago";

  # Same layout as the old Debian /etc/network/interfaces:
  #   br0: lan0 (onboard 1)           192.168.1.50/24, default route
  #   br1: lan0 VLAN 500              10.10.10.50/24
  #   br2: wan0 (onboard 2)           10.4.4.50/24 (ex "pfsense WAN")
  # NICs pinned by MAC so names survive PCI renumbering.
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    links = {
      "10-lan0" = {
        matchConfig.PermanentMACAddress = "00:25:90:02:fb:a6";
        linkConfig.Name = "lan0";
      };
      "10-wan0" = {
        matchConfig.PermanentMACAddress = "00:25:90:02:fb:a7";
        linkConfig.Name = "wan0";
      };
    };
    netdevs = {
      "20-br0".netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
      "20-br1".netdevConfig = {
        Kind = "bridge";
        Name = "br1";
      };
      "20-br2".netdevConfig = {
        Kind = "bridge";
        Name = "br2";
      };
      "20-vlan500" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan500";
        };
        vlanConfig.Id = 500;
      };
    };
    networks = {
      "30-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig.Bridge = "br0";
        vlan = [ "vlan500" ];
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-vlan500" = {
        matchConfig.Name = "vlan500";
        networkConfig.Bridge = "br1";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig.Bridge = "br2";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        address = [ "192.168.1.50/24" ];
        routes = [ { Gateway = "192.168.1.33"; } ];
        linkConfig.RequiredForOnline = "routable";
      };
      "40-br1" = {
        matchConfig.Name = "br1";
        address = [ "10.10.10.50/24" ];
        linkConfig.RequiredForOnline = "no";
      };
      "40-br2" = {
        matchConfig.Name = "br2";
        address = [ "10.4.4.50/24" ];
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
  # VMs attach to the bridges; their traffic must not hit the host firewall
  networking.firewall.trustedInterfaces = [
    "br0"
    "br1"
    "br2"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
    allowedBridges = [
      "br0"
      "br1"
      "br2"
    ];
  };

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$ysACyCk2sIkE4gjt8JfgK0$ZS1H7jaFrrMbZj1QGX2xm/omN8rGAwl6cAcZbfKQykC";
      extraGroups = [
        "wheel"
        "libvirtd"
      ];
    };
    sudo.enable = true;
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    mdadm
  ];
}
