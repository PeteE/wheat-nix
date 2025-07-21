{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    kubectx
    kubernetes-helm
  ];
}
