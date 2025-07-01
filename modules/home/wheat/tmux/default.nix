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
      default = 100000;
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
      tmuxinator.enable = true;

      plugins = with pkgs; [
        { plugin = tmuxPlugins.tmux-fzf; }
        { plugin = tmuxPlugins.urlview; }
        { plugin = tmuxPlugins.fuzzback; }
        { plugin = tmuxPlugins.extrakto; }
        tmuxPlugins.yank
        tmuxPlugins.open
        tmuxPlugins.copycat
        tmuxPlugins.sensible
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            # defaults
            # set -g @resurrect-save 's'
            # set -g @resurrect-restore 'r'
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style "rounded"
          '';
        }
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        # tmuxPlugins.session-wizard
        # tmuxPlugins.prefix-highlight
      ];
      shortcut = "a";  # Ctrl-a
      mouse = true;
      newSession = true;
      sensibleOnTop = true;
      extraConfig = ''
        set -g set-clipboard on
        set -g @scroll-without-changing-pane "on"

        # split windows
        bind | split-window -h
        bind - split-window -v

        # hjkl pane traversal
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # clear screen
        bind C-l send-keys 'C-l'

        bind-key V select-layout even-vertical
        bind-key H select-layout even-horizontal
        bind-key T select-layout tiled

        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -agF status-right "#{E:@catppuccin_status_cpu}"
        set -ag status-right "#{E:@catppuccin_status_session}"
        set -ag status-right "#{E:@catppuccin_status_uptime}"
        set -agF status-right "#{E:@catppuccin_status_battery}"
        setenv -g PATH "$HOME/bin:$PATH"
        set-option -sa terminal-features ',xterm-kitty:RGB'
        set-option -sa terminal-features ',xterm-kitty:RGB'
      '';
    };
    home.packages = with pkgs; [
      lsof
      file
      thumbs
    ];
  };
}

