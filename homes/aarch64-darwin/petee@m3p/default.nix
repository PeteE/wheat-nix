{
  home,
  pkgs,
  inputs,
  system,
  ...
}:
{
  wheat = {
    ollama.enable = false;
    git.managedConfig = false;
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
    codex
    azure-storage-azcopy
    inputs.nixpkgs-stable.legacyPackages."${system}".tailscale
    python312Packages.huggingface-hub
    moonlight-qt
    # gateway API cli
    pkgs.wheat.gwctl
  ];
  home.sessionVariables = {
    AZCOPY_AUTO_LOGIN_TYPE = "AZCLI";
  };
  home.stateVersion = "26.05";
}
