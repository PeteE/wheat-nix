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
    programs.carapace = {
      enableZshIntegration = true;
    };
    programs.zsh.initContent =
      lib.mkOrder 2000 ''
        bindkey '^r' atuin-search

        # bind to the up key, which depends on terminal mode
        bindkey '^[[A' atuin-up-search
        bindkey '^[OA' atuin-up-search

        # # Just enable basic zsh completion caching globally
        # zstyle ':completion:*' use-cache yes
        # zstyle ':completion:*' cache-path ~/.zsh/cache
        # zstyle ':completion:*' cache-policy _my_cache_policy

        # _my_cache_policy() {
        #     # Cache for 2 hours
        #     [[ -n "$1" && "$1" -ot =(( CURRENT_TIME - 7200 )) ]]
        # }

        # # Completion formatting
        # zstyle ':completion:*' format $'\e[2;37mCompleting %d ...\e[m'

        # # source <(carapace az zsh)

        # # # Override slow built-in az completion with carapace
        # # compdef _az_completion az

        # # Optional: completely remove the slow _az function to prevent accidental use
        # # unfunction _az 2>/dev/null

        source <(${lib.getExe pkgs.atuin} init zsh)
      '';
  };
}

