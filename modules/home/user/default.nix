{ lib, config, pkgs, osConfig ? { }, ... }:
let
  inherit (lib) types mkIf mkDefault mkMerge;

  cfg = config.wheat.user;

  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null then
      null
    else if is-darwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.wheat.user = {
    enable = mkEnableOption "Whether to configure the user account.";
    name = mkOption {
      default = config.snowfallorg.user.name;
      description = "The user account to create";
      type = types.str
    };
    home = mkOption {
      default = home-directory;
      description = "The user's home directory.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # this is a nixos module setting not home-manager
    home = {
      username = cfg.name;
      homeDirectory = cfg.home;
    };
  };
}
