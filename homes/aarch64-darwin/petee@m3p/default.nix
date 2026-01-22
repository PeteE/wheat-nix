{
  home,
  pkgs,
  ...
}:
{
  wheat = {
    work.enable = true;
    minikube.enable = true;
    secrets = {
      enable = true;
    };
    misc.enable = true;
    azure.enable = true;
    aws.enable = true;
    dev-tools.enable = true;
    ai.enable = true;
    gcloud.enable = true;
    embedded.enable = false;
    yazi.enable = true;
    attic-client.enable = true;
  };
  home.packages = with pkgs; [
    vault
  ];
  home.stateVersion = "25.11";
}
