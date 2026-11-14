# vim: ts=2:sw=2:et
#
# TFTP server handing out the netboot.xyz UEFI iPXE binary. DHCP is not
# served here: the router's dnsmasq points UEFI PXE clients at this host via
#   dhcp-match=set:efi64,option:client-arch,7
#   dhcp-boot=tag:efi64,netboot.xyz.efi,,<this host>
# After loading, iPXE pulls its menus over HTTPS from boot.netboot.xyz.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.netboot;

  # Fetched directly instead of pkgs.netbootxyz-efi:
  # - nixpkgs ships 2.0.88; netboot.xyz 3.0.0 rotated its code-signing CA, so
  #   pre-3.x bootloaders fail on the live menus with "Could not verify:
  #   Permission denied" (https://ipxe.org/0216eb8f)
  # - netbootxyz-efi picks the binary for its host platform, which on an
  #   aarch64 server (rpi4) is the ARM64 build; the clients are x86-64
  netbootxyzEfi = pkgs.fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.3/netboot.xyz.efi";
    hash = "sha256-Vrsh6fbXnq25R+cDGgiMmvzEiqHrmbJQLRYfCxxYaoI=";
  };

  # The .efi is a single file; wrap it in a directory
  tftpRoot = pkgs.linkFarm "netboot-tftp-root" [
    {
      name = "netboot.xyz.efi";
      path = cfg.efiPackage;
    }
  ];
in
{
  options.wheat.services.netboot = {
    enable = mkEnableOption "netboot.xyz TFTP server (UEFI)";

    efiPackage = mkOption {
      type = types.package;
      default = netbootxyzEfi;
      defaultText = literalExpression "netboot.xyz 3.0.3 x86-64 netboot.xyz.efi";
      description = "netboot.xyz UEFI binary (x86-64) served as netboot.xyz.efi";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open UDP 69 for TFTP";
    };
  };

  config = mkIf cfg.enable {
    services.atftpd = {
      enable = true;
      root = "${tftpRoot}";
    };

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 69 ];
  };
}
