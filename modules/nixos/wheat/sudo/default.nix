{
  config,
  pkgs,
  lib,
  ...
}:
{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
