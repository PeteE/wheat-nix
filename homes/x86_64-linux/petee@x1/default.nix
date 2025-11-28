{ 
  inputs,
  pkgs,
  system,
  ... 
}:
{
  
  wheat = {
    ollama.enable = false;
    distrobox.enable = true;
    ai = {
      enable = true;
      ollamaHost = "192.168.1.115"; # m4
      mcp.enable = true;
      claude-sessions.enable = true;
      aichat.enable = true;
      opencommit.enable = false;
      ccr.enable = false;
    };

    misc.enable = true;
    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    firefox.enable = true;
    hyprland.enable = true;
    minikube.enable = true;
    devenv.enable = true;
    zed-editor.enable = true;
    vscode.enable = true;
    azure.enable = true;
    dev-tools.enable = true;
    gcloud.enable = true;
    embedded.enable = true;
    attic-client.enable = true;
  };

  services.hyprsunset.enable = true;
  services.mako = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
