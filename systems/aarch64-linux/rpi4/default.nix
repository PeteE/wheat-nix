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
  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.initrd.allowMissingModules = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = false;
  networking.hostName = "rpi4";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "America/Chicago";

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$ysACyCk2sIkE4gjt8JfgK0$ZS1H7jaFrrMbZj1QGX2xm/omN8rGAwl6cAcZbfKQykC";
      extraGroups = [
        "wheel"
        "NetworkManager"
        "dialout"
      ];
    };
    sudo.enable = true;
    secrets.enable = true;
    wifi.enable = true;
  };
  services.tailscale.enable = true;

  # Cloudflare Dynamic DNS
  sops.age.keyFile = "/home/petee/.config/sops/age/keys.txt";
  wheat.services.cloudflare-dyndns = {
    enable = true;
    domains = [
      "wheat-dn42.net"
      "edge-public.wheat-dn42.net"
    ];
    frequency = "*:0/5";  # every 5 minutes
    ipv4 = true;
    ipv6 = false;
    proxied = false;
  };

  # Caddy reverse proxy with Cloudflare DNS-01 ACME
  wheat.services.caddy = {
    enable = true;
    email = "pete.perickson@gmail.com";
    virtualHosts = {
      "adguard.wheat-dn42.net" = { upstream = "localhost:3000"; };
    };
  };

  # AdGuard Home DNS ad blocker
  wheat.services.adguardhome = {
    enable = true;
    port = 3000;  # web UI
    dnsPort = 53;
    openFirewall = true;
    mutableSettings = true;
    dnsRewrites = [
      # App infrastructure (K8s ingress)
      { domain = "unifi.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "hs.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "reg.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "authentik.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "s3.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "idp.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Automation
      { domain = "mqtt.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "node-red.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Media
      { domain = "overseerr.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Apps
      { domain = "hastebin.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Local network
      { domain = "gw"; answer = "192.168.1.33"; }
      { domain = "freenas.wheat-dn42.net"; answer = "192.168.1.120"; }
      { domain = "nas.wheat-dn42.net"; answer = "192.168.1.120"; }
      { domain = "nas"; answer = "192.168.1.120"; }
      { domain = "hv"; answer = "192.168.1.50"; }
      { domain = "ripper"; answer = "192.168.1.51"; }
    ];
  };

  system.stateVersion = "25.11";
  nix.settings.trusted-users = [ "root" "petee" "pete" ];
  # nix.settings.substituters = [ "https://nix-cache-dev.corp.tooling.opaque-int.com/opaque" ];
}
