{ pkgs, lib, ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;
}
