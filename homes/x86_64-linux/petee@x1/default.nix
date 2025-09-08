{ ... }:
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

    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
  };
  home.stateVersion = "25.11";

}
