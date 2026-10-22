{
  home,
  ...
}:
{
  wheat = {
    embedded.enable = false;
    secrets.enable = true;
    aws.enable = true;
    tor.enable = false;
  };
  home.stateVersion = "26.05";
}
