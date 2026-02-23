{
  home,
  pkgs,
  inputs,
  system,
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
    ai.mcp.enable = true;
    gcloud.enable = true;
    embedded.enable = false;
    yazi.enable = true;
    attic-client.enable = true;
  };
  home.packages = with pkgs; [
    vault
    inputs.nixpkgs-stable.legacyPackages."${system}".tailscale
    python312Packages.huggingface-hub
  ];
  home.stateVersion = "25.11";
}
