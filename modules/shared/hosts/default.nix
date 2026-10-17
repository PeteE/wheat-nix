# vim: ts=2:sw=2:et
# LAN /etc/hosts entries for every host. Imported by modules/shared/wheat
# (NixOS) and modules/darwin/wheat/basic (nix-darwin).
#
# NixOS: appended via networking.extraHosts (NixOS owns /etc/hosts already).
# darwin: nix-darwin has no hosts option, so the whole file is managed via
#   environment.etc."hosts". nix-darwin only replaces an existing /etc file
#   whose sha256 is listed in darwinKnownSha256Hashes; on a new Mac either add
#   its hash or `sudo mv /etc/hosts /etc/hosts.before-nix-darwin` first.
{
  config,
  lib,
  options,
  ...
}:
with lib;
let
  cfg = config.wheat.hosts;
  isNixOS = options ? networking && options.networking ? extraHosts;
in
{
  options.wheat.hosts = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Manage LAN host entries in /etc/hosts";
    };
    entries = mkOption {
      type = types.lines;
      description = "LAN host entries";
      default = ''
        # infra
        192.168.1.33    gw         # router
        192.168.1.3     switch0    # hp switch
        192.168.1.4     ap0        # netgear AP
        192.168.1.159   usw-petee  # switch
        192.168.1.196   usw-sam    # switch

        # computers
        192.168.1.7     x1
        192.168.1.143   ripnix
        192.168.1.115   m4-wifi
        192.168.1.149   m4
        192.168.1.50    hv
        192.168.1.51    ripper
        192.168.1.120   trunas
        192.168.1.222   rpi0
        192.168.1.173   rpi4

        # devices
        192.168.1.116   pixel-7a
        192.168.1.140   pixel10
        192.168.1.186   joannas-ipad
        192.168.1.185   petee-ipad
        192.168.1.195   mariannes-air
        192.168.1.209   m3p-wifi
        192.168.1.210   m3p
        192.168.1.221   meshtastic0
        192.168.1.151   meshtastic1-v4
        192.168.1.155   redboard
        192.168.1.131   esp32mini

        # k8s nodes
        192.168.1.202   k8s-master0
        192.168.1.162   k8s-worker-100
        192.168.1.133   k8s-worker-200

        # misc / iot
        192.168.1.32    printer
        192.168.1.168   appletv
        192.168.1.132   rachio
        192.168.1.139   myq
        192.168.1.125   nest-door
        192.168.1.160   nest-driveway
        192.168.1.150   nest-backyard
        192.168.1.171   home-mini-bedroom
        192.168.1.226   xboxone-fam
        192.168.1.220   xboxone-sam
        192.168.1.182   chromecast
      '';
    };
    darwinKnownSha256Hashes = mkOption {
      type = types.listOf types.str;
      description = "sha256 of pre-existing /etc/hosts files nix-darwin may replace";
      default = [
        "d65f7919387b07b31af4327ae153995b756c0ace5a3cbfd695d84373f442b293" # m3p (2026-10-17)
      ];
    };
  };

  config = mkIf cfg.enable (
    if isNixOS then
      { networking.extraHosts = cfg.entries; }
    else
      {
        environment.etc."hosts" = {
          text = ''
            ##
            # Host Database (managed by nix-darwin, see modules/shared/hosts)
            ##
            127.0.0.1       localhost
            255.255.255.255 broadcasthost
            ::1             localhost

          ''
          + cfg.entries;
          knownSha256Hashes = cfg.darwinKnownSha256Hashes;
        };
      }
  );
}
