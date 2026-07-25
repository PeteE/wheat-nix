# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  modulesPath,
  ...
}:
with lib;
let
  cfg = config.wheat.starship;
in
{
  options.wheat.starship = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    # We manage starship.toml ourselves below; avoid colliding with
    # catppuccin/nix's own starship port writing the same target path.
    catppuccin.starship.enable = false;

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
    xdg.configFile."starship.toml" = {
      source = ./starship.toml;
    };
  };
}
