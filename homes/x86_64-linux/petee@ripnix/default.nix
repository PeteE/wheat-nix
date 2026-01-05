{
    home,
    ...
}:
{
  wheat = {
    ollama.enable = false;
    ai = {
      enable = true;
      ollamaHost = "192.168.1.115"; # m4
      mcp.enable = true;
    };
    work.enable = true;
    misc.enable = true;
    vscode.enable = true;
    azure.enable = true;
    dev-tools.enable = true;
    gcloud.enable = true;
    embedded.enable = true;
    attic-client.enable = true;
  };
  home.stateVersion = "25.11";
}
