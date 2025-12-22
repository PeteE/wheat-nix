{
    home,
    ...
}:
{
  wheat = {
    embedded.enable = true;
    services.tailscale.enable = true;
  };
  home.stateVersion = "25.11";
}
