{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  format, # A normalized name for the home target (eg. `home`).
  virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
  host, # The host name for this home.
  config,
  ...
}:
with lib; let
  cfg = config.wheat.atuin;
in {
  options.wheat.atuin = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      atuin
    ];

    xdg.configFile."atuin.toml" = {
       source = ./.config/atuin/config.toml;
       target = "atuin/config.toml";
    };
    # TODO(pete) not sure why this is here.... should be a new module
    programs.zsh.initContent =
      lib.mkOrder 2000 ''
        # bindkey '^r' atuin-search

        # bind to the up key, which depends on terminal mode
        # bindkey '^[[A' atuin-up-search
        # bindkey '^[OA' atuin-up-search

        # source <(${lib.getExe pkgs.atuin} init zsh)
      '';
  };
}
