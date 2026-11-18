# vim: ts=2:sw=2:et
#
# Tailscale that joins the tailnet on its own as a tagged node, using the
# client devices' OAuth client secret (auth_keys scope) as the auth key.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.services.tailscale;
in
{
  options.wheat.services.tailscale = {
    enable = mkEnableOption "tailscale, auto-joined as a tagged node";

    tags = mkOption {
      type = types.listOf types.str;
      default = [ "tag:device" ];
      description = "ACL tags to advertise; the OAuth client must own them";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--advertise-tags=${concatStringsSep "," cfg.tags}" ];
      # OAuth client secret used directly as the auth key; tagged nodes don't
      # expire. Only used while logged out, so existing nodes keep their
      # identity until re-tagged in the admin console or logged out
      authKeyFile = config.sops.secrets."tailscale/client-auth-key".path;
      authKeyParameters = {
        ephemeral = false;
        preauthorized = true;
      };
    };

    # Decrypted with the host's SSH key (sops.age.sshKeyPaths default); the
    # host must be a recipient in .sops.yaml. Distinct name so it can't clash
    # with k3s-agent's tailscale/client-secret
    sops.secrets."tailscale/client-auth-key" = {
      sopsFile = ./secrets/tailscale.yaml;
      key = "tailscale/client-secret";
    };
    systemd.services.tailscaled-autoconnect = {
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
    };
  };
}
