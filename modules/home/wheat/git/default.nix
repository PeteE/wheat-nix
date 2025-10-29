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
with lib; let
  cfg = config.wheat.git;
  theme = "git/theme.gitconfig";
in {
  options.wheat.git = with types; {
    enable = mkEnableOption "Enable";
    openCommit = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    xdg.configFile."${theme}" = {
      source = ./catppuccin.gitconfig;
    };

    home.packages = mkIf cfg.openCommit [
      pkgs.opencommit
    ];
    programs.git = {
      enable = true;
      lfs.enable = true;

      extraConfig = {
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
      delta = {
        enable = false;
        options = {
          navigate = true;
          dark = true;
        };
      };
    };
  };
}
