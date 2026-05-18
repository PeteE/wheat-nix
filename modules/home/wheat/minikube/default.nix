{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.minikube;
in
{
  options.wheat.minikube = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      minikube
    ];
  };
}
