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
  ...
}:
with lib;
let
  cfg = config.wheat.git;
  theme = "git/theme.gitconfig";
in
{
  options.wheat.git = with types; {
    enable = mkEnableOption "Enable";
    openCommit = mkEnableOption "Enable";
    managedConfig = mkOption {
      type = bool;
      default = true;
      description = "Whether home-manager manages the git config (read-only symlink). When false, git/delta are installed as packages and the config is seeded as a mutable file.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common config shared by both modes
    {
      xdg.configFile."${theme}" = {
        source = ./catppuccin.gitconfig;
      };
      home.sessionVariables = {
        GIT_EDITOR = "${pkgs.neovim}/bin/nvim";
      };
    }

    # Managed mode: home-manager owns the git config (read-only symlink)
    (mkIf cfg.managedConfig {
      programs.git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user = {
            email = "pete.perickson@gmail.com";
            name = "PeteE";
          };
          core = {
            editor = "${pkgs.neovim}/bin/nvim";
          };

          # TODO(pete): This was a cluade suggested hack since i'm having issues with libsecret on macos
          credential = {
            "https://github.com" = {
              helper = "!f() { echo username=petee; echo password=$(${pkgs.gh}/bin/gh auth token); }; f";
            };
          };

          # merge = {
          #   conflictstyle = "zdiff3";
          #   tool = "meld";
          #   path = "${pkgs.meld}/bin/meld";
          # };
          # diff = {
          #   tool = "meld";
          #   path = "${pkgs.meld}/bin/meld";
          # };
          # mergetool = {
          #   tool = "meld";
          #   path = "${pkgs.meld}/bin/meld";
          # };

          pull.rebase = "false";
          push.default = "current";

          # include = [
          #   {
          #     path = "${config.xdg.configHome}/${theme}";
          #   }
          #   {
          #     path = "~/.config/git/config.local";
          #   }
          # ];
          include = {
            path = "~/.config/git/config.local";
          };
        };

        hooks = mkIf cfg.openCommit {
          prepare-commit-msg = "${pkgs.opencommit}/bin/oco hook run";
        };

        # TODO: gpg signing

        # Pretty diffs: https://github.com/dandavison/delta
        # delta = {
        #   enable = false;
        #   options = {
        #     navigate = true;
        #     dark = true;
        #   };
        # };
      };
      programs.delta = {
        enable = true;
      };
    })

    # Unmanaged mode: install packages, seed mutable config
    (mkIf (!cfg.managedConfig) {
      home.packages = with pkgs; [
        git
        git-lfs
        delta
      ];

      home.activation.seedGitConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
                gitconfig="${config.xdg.configHome}/git/config"
                if [ ! -f "$gitconfig" ] || [ -L "$gitconfig" ]; then
                  # Remove stale symlink from previous managed mode
                  rm -f "$gitconfig"
                  mkdir -p "$(dirname "$gitconfig")"
                  cat > "$gitconfig" << 'GITCFG'
        [user]
        	email = pete.perickson@gmail.com
        	name = PeteE
        [core]
        	editor = ${pkgs.neovim}/bin/nvim
        [credential "https://github.com"]
        	helper = !f() { echo username=petee; echo password=$(${pkgs.gh}/bin/gh auth token); }; f
        [pull]
        	rebase = false
        [push]
        	default = current
        [include]
        	path = ~/.config/git/config.local
        GITCFG
                  run echo "Seeded mutable git config at $gitconfig"
                fi
      '';
    })
  ]);
}
