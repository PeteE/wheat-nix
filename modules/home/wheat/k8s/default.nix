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
 };
 config = mkIf cfg.enable {
   home.packages = with pkgs; [
     kubectx
     kubernetes-helm
     kubectl
   ];
 };
}
