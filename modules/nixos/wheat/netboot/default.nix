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

  # netbootxyz-efi's output is the .efi file itself; wrap it in a directory
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
      # netbootxyz-efi picks the binary for its host platform, so on an
      # aarch64 server (rpi4) plain pkgs.netbootxyz-efi is the ARM64 build.
      # The clients are x86-64; it's only a fetchurl, so cross costs nothing.
      default = pkgs.pkgsCross.gnu64.netbootxyz-efi;
      defaultText = literalExpression "pkgs.pkgsCross.gnu64.netbootxyz-efi";
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
