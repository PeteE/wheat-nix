{
  home,
  ...
}:
{
  wheat = {
    embedded.enable = true;
    secrets.enable = true;
    aws.enable = true;
    tor.enable = true;
  };
  home.stateVersion = "25.11";
}
