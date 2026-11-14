# vim: ts=2:sw=2:et
#
# k3s worker joining the existing cluster (server k8s-master-000), plus the
# host bits democratic-csi expects for TrueNAS iSCSI / NVMe-oF volumes.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.k3s-agent;
in
{
  options.wheat.services.k3s-agent = {
    enable = mkEnableOption "k3s agent (worker node)";

    package = mkOption {
      type = types.package;
      # Keep the minor version in step with the server; kubelet must not be
      # newer than the API server
      default = pkgs.k3s_1_35;
      defaultText = literalExpression "pkgs.k3s_1_35";
      description = "k3s package";
    };

    serverAddr = mkOption {
      type = types.str;
      default = "https://192.168.1.202:6443";
      description = "k3s server URL to join";
    };

    tokenFile = mkOption {
      type = types.path;
      default = "/var/lib/rancher/k3s/agent-token";
      description = "File holding the cluster agent join token (kept out of the store)";
    };

    nodeLabels = mkOption {
      type = types.attrsOf types.str;
      # system-upgrade-controller's agent-plan must skip this node: k3s here
      # is managed by Nix, not by the plan's binary swap
      default = {
        "k3s-upgrade" = "false";
      };
      description = "Labels applied when the node registers";
    };
  };

  config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "agent";
      inherit (cfg) package serverAddr tokenFile;
      extraFlags = concatStringsSep " " (
        mapAttrsToList (k: v: "--node-label=${k}=${v}") cfg.nodeLabels
      );
    };

    # democratic-csi iSCSI
    services.openiscsi = {
      enable = true;
      name = "iqn.2026-11.net.wheat-dn42:${config.networking.hostName}";
    };
    # democratic-csi runs `chroot /host /usr/bin/env -i PATH=/sbin:/bin:/usr/bin
    # iscsiadm`; NixOS has nothing on that PATH, so link it in
    systemd.tmpfiles.rules = [
      "L+ /usr/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
    ];

    # democratic-csi NVMe-oF (nvme-tcp); the driver pod can't modprobe from
    # NixOS's module path, so load them at boot
    boot.kernelModules = [
      "nvme_tcp"
      "nvme_fabrics"
    ];
    environment.systemPackages = with pkgs; [
      nvme-cli
      openiscsi
    ];
  };
}
