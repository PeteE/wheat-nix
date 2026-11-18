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

  config = mkIf cfg.enable (mkMerge [
    {
      services.k3s = {
        enable = true;
        role = "agent";
        inherit (cfg) package serverAddr tokenFile;
        extraFlags = concatStringsSep " " (mapAttrsToList (k: v: "--node-label=${k}=${v}") cfg.nodeLabels);
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

      # in-tree `nfs:` volumes; kubelet shells out to mount, which needs the
      # mount.nfs helper from nfs-utils (and rpcbind for NFSv3)
      boot.supportedFilesystems = [ "nfs" ];
    }

    (mkIf config.services.tailscale.enable {
      services.tailscale = {
        # MagicDNS would rewrite the node's resolver (100.100.100.100 + tailnet
        # search domain), which CoreDNS and dnsPolicy=Default pods inherit.
        # extraSetFlags is applied on every start, so it also covers nodes that
        # were logged in by hand
        extraSetFlags = [ "--accept-dns=false" ];
        # Never add --accept-routes here: rpi4 advertises 192.168.1.0/24 and
        # tailscale would steal node-to-node (flannel) traffic from the LAN
        extraUpFlags = [
          "--accept-dns=false"
          "--advertise-tags=tag:k8s-node"
        ];
        # OAuth client secret (auth_keys scope, tag:k8s-node) used directly as
        # the auth key; tagged nodes don't expire
        authKeyFile = config.sops.secrets."tailscale/client-secret".path;
        authKeyParameters = {
          ephemeral = false;
          preauthorized = true;
        };
      };

      # Decrypted with the host's SSH key (sops.age.sshKeyPaths default); the
      # host must be a recipient in .sops.yaml
      sops.secrets."tailscale/client-secret".sopsFile = ./secrets/tailscale.yaml;
      systemd.services.tailscaled-autoconnect = {
        after = [ "sops-nix.service" ];
        wants = [ "sops-nix.service" ];
      };
    })
  ]);
}
