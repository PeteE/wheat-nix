{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.k8s;
in {
  options.wheat.k8s = {
    enable = mkEnableOption "Enable";
    argocd = {
      enable = mkEnableOption "Enable ArgoCD CLI";
      server = mkOption {
        description = "ArgoCD server URL";
        default = "cd.wheat-dn42.net";
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectx
      kubernetes-helm
      kubectl
      krew
    ] ++ optionals cfg.argocd.enable [
      argocd
    ];

    sops.secrets.argocdAuthToken = mkIf cfg.argocd.enable { };

    programs.zsh.envExtra = mkIf cfg.argocd.enable ''
      export ARGOCD_SERVER=${cfg.argocd.server}
      export ARGOCD_AUTH_TOKEN=$(cat ${config.sops.secrets.argocdAuthToken.path})
      export ARGOCD_OPTS="--grpc-web"
    '';
  };
}
