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
  };
  config = mkIf cfg.enable {
    xdg.configFile."${theme}" = {
      source = ./catppuccin.gitconfig;
    };

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

        include = {
          path = "${config.xdg.configHome}/${theme}";
        };
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
