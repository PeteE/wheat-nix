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
      aichat.enable = false;
      opencommit.enable = false;
      ccr.enable = false;
    };

    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    firefox.enable = true;
    hyprland.enable = true;
    minikube.enable = true;
    devenv.enable = true;
    zed-editor.enable = true;
  };

  services.hyprsunset.enable = true;
  services.mako = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
