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
    };
    work.enable = true;
  };
  home.stateVersion = "25.11";
}
