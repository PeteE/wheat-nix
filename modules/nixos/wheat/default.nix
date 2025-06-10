{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  services.openssh.enable = true;
}
