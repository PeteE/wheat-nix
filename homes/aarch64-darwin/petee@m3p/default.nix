{
  home,
  pkgs,
  ...
}:
{
  wheat = {
    ai = {
      enable = true;
    };
    work.enable = true;
    minikube.enable = true;
    secrets = {
      enable = true;
    };
  };
  home.packages = with pkgs; [
    minikube
    vault
  ];
  home.stateVersion = "25.11";
}
