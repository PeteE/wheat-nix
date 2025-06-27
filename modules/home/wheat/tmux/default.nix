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
  cfg = config.wheat.tmux;
in {
  options.wheat.tmux = {
    enable = mkEnableOption "Enable";
    terminal = mkOption {
      default = "xterm-kitty";
      type = types.str;
    };
    historyLimit = mkOption {
      default = 20000;
      type = types.ints.unsigned;
    };
    keyMode = mkOption {
      default = "vi";
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = cfg.terminal;
      secureSocket = true;
      historyLimit = cfg.historyLimit;
      keyMode = cfg.keyMode;
      tmuxp.enable = true;
      # tmuxinator.enable = true;
      plugins = with pkgs; [
        # { plugin = tmuxPlugins.tmux-fzf; }
        # { plugin = tmuxPlugins.urlview; }
        # { plugin = tmuxPlugins.fuzzback; }
        # { plugin = tmuxPlugins.extrakto; }
        tmuxPlugins.yank
        tmuxPlugins.open
        tmuxPlugins.copycat
        # tmuxPlugins.sensible
        # tmuxPlugins.resurrect
        tmuxPlugins.catppuccin
        #{
        #    plugin = tmuxPlugins.continuum;
        #    #extraConfig = "set -g @continuum-boot-options 'kitty'";
        #}
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        # tmuxPlugins.session-wizard
        # tmuxPlugins.prefix-highlight
      ];
      extraConfig = builtins.readFile ./tmux.conf;
    };
    # xdg.configFile."tmuxinator/" = {
    #     source = ./tmuxinator;
    # };
    home.packages = with pkgs; [
      lsof
      file
      thumbs
    ];
    programs.zsh.shellAliases.mux = "tmuxinator";
  };
}

