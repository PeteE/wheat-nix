{
    home,
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
    };
    rofi.enable = true;
    work.enable = true;
  };
  home.stateVersion = "25.11";
}
