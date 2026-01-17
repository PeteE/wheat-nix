{
    home,
    ...
}:
{
  wheat = {
    embedded.enable = true;
    aws.enable = true;
    tor.enable = true;
    secrets.enable = true;
  };
  home.stateVersion = "25.11";
}
