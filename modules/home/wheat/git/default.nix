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
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";

        merge = {
          # conflictstyle = "zdiff3";
          tool = "meld";
          path = "${pkgs.meld}/bin/meld";
        };
        diff = {
          tool = "meld";
          path = "${pkgs.meld}/bin/meld";
        };
        mergetool = {
          tool = "meld";
          path = "${pkgs.meld}/bin/meld";
        };

        pull.rebase = "false";
        push.default = "current";

        include = {
          path = "${config.xdg.configHome}/${theme}";
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
