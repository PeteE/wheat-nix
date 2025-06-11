# vim: ts=2:sw=2:et
{ options, config, lib, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."starship.toml" = {
      source = ./starship.toml;
  };
}
