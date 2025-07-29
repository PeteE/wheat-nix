{
  pkgs,
  home,
  ...
}:
{
  wheat = {
    ollama.enable = true;
    secrets = {
      enable = true;
    };
  };
  home.packages = with pkgs; [
    spotify
  ];
  home.stateVersion = "25.11";
}
