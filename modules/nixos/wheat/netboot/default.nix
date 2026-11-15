# vim: ts=2:sw=2:et
#
# TFTP server handing out the netboot.xyz iPXE binaries. DHCP is not served
# here: the router's dnsmasq points PXE clients at this host via
#   dhcp-match=set:efi64,option:client-arch,7     (UEFI x86-64)
#   dhcp-boot=tag:efi64,netboot.xyz.efi,,<this host>
#   dhcp-match=set:bios,option:client-arch,0      (legacy BIOS, e.g. hv)
#   dhcp-boot=tag:bios,netboot.xyz.kpxe,,<this host>
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
  # The -legacy build omits iPXE's USB NIC drivers, which in 3.x unhook the
  # firmware's USB keyboard (dead keyboard at the menu on the ThinkCentre).
  # Trade-off: no USB ethernet adapters. See
  # https://netboot.xyz/docs/kb/hardware/usb-keyboard
  netbootxyzEfi = pkgs.fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.3/netboot.xyz-legacy.efi";
    hash = "sha256-xns+RnTf5ZJ71ujLSiA+VCLlCiyPWQ6ZGSlKX5ONWMQ=";
  };
  # Legacy BIOS PXE (undionly-style .kpxe); -legacy for the same USB reason
  netbootxyzKpxe = pkgs.fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.3/netboot.xyz-legacy.kpxe";
    hash = "sha256-eXSGgzoG8z1J6bxzCZO0V3D4olkuHebSiitsJ+t90I4=";
  };

  # Each bootloader is a single file; wrap them in a directory
  tftpRoot = pkgs.linkFarm "netboot-tftp-root" [
    {
      name = "netboot.xyz.efi";
      path = cfg.efiPackage;
    }
    {
      name = "netboot.xyz.kpxe";
      path = cfg.biosPackage;
    }
  ];
in
{
  options.wheat.services.netboot = {
    enable = mkEnableOption "netboot.xyz TFTP server (UEFI + legacy BIOS)";

    efiPackage = mkOption {
      type = types.package;
      default = netbootxyzEfi;
      defaultText = literalExpression "netboot.xyz 3.0.3 x86-64 netboot.xyz-legacy.efi";
      description = "netboot.xyz UEFI binary (x86-64) served as netboot.xyz.efi";
    };

    biosPackage = mkOption {
      type = types.package;
      default = netbootxyzKpxe;
      defaultText = literalExpression "netboot.xyz 3.0.3 netboot.xyz-legacy.kpxe";
      description = "netboot.xyz legacy BIOS PXE binary served as netboot.xyz.kpxe";
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
