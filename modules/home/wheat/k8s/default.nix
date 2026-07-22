{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.k8s;
in
{
  options.wheat.k8s = {
    enable = mkEnableOption "Enable";
    argocd = {
      enable = mkEnableOption "Enable ArgoCD CLI";
      server = mkOption {
        description = "ArgoCD server URL";
        default = "cd.wheat-dn42.net";
        type = types.str;
      };
      useAuthTokenSecret = mkOption {
        description = "Export ARGOCD_AUTH_TOKEN from the sops-managed argocdAuthToken secret. Disable for hosts that authenticate interactively (e.g. via `argocd login --sso`) against a server other than the homelab.";
        default = true;
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        kubectx
        kubernetes-helm
        kubectl
        kubectl-gadget # inspektor gadget plugin
        krew
      ]
      ++ optionals cfg.argocd.enable [
        argocd
      ];

    sops.secrets.argocdAuthToken = mkIf (cfg.argocd.enable && cfg.argocd.useAuthTokenSecret) { };

    programs.zsh.envExtra = ''
      export KUBECTL_EXTERNAL_DIFF="diff -u"
    ''
    + optionalString cfg.argocd.enable ''
      export ARGOCD_SERVER=${cfg.argocd.server}
      export ARGOCD_OPTS="--grpc-web"
    ''
    + optionalString (cfg.argocd.enable && cfg.argocd.useAuthTokenSecret) ''
      export ARGOCD_AUTH_TOKEN=$(cat ${config.sops.secrets.argocdAuthToken.path})
    '';
  };
}
