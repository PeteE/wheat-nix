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
with lib; let
  cfg = config.wheat.starship;
in {
  options.wheat.starship = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      starship
    ];
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
        # format = "$hostname$directory$git_branch$git_commit$git_state$git_status\
# $fill\
# $jobs$status$cmd_duration\
# $nix_shell$terraform$kubernetes$python$aws$nodejs$docker_context$golang$time$os
# $character",

    };
    xdg.configFile."starship.toml" = {
      source = ./starship.toml;
    };
  };
}
