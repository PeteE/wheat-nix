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
  tmux-35 = pkgs.tmux.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) pname;
    version = "3.5";
    src = pkgs.fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "${version}";
      sha256 = "sha256-8CRZj7UyBhuB5QO27Y+tHG62S/eGxPOHWrwvh1aBqq0=";
    };
  });
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
      package = tmux-35;
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = cfg.terminal;
      secureSocket = true;
      historyLimit = cfg.historyLimit;
      keyMode = cfg.keyMode;
      tmuxp.enable = true;
      plugins = with pkgs; [
        tmuxPlugins.sensible
        { 
          plugin = tmuxPlugins.tmux-fzf;
          extraConfig = ''
            #TMUX_FZF_ORDER="session|window|pane|command|keybinding|clipboard|process"
            TMUX_FZF_ORDER="session|window|pane"
          '';
        }
        { plugin = tmuxPlugins.urlview; }
        # { plugin = tmuxPlugins.fuzzback; }  # TODO(pete)
        {
          plugin = tmuxPlugins.yank;
          extraConfig = ''
            # vim-like visual selection keybindings
            bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
            bind-key -T copy-mode-vi 'V' send-keys -X rectangle-toggle
          '';
        }
        tmuxPlugins.open
        tmuxPlugins.copycat
        {
          plugin = tmuxPlugins.tmux-thumbs;
          # extraConfig = ''
          #   set -g @thumbs-key F
          #   set -g @thumbs-osc52 1
          # '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style "rounded"

            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_application}"
            set -agF status-right "#{E:@catppuccin_status_cpu}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            # set -ag status-right "#{E:@catppuccin_status_uptime}"
            # set -agF status-right "#{E:@catppuccin_status_battery}"


          '';
        }
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        # tmuxPlugins.session-wizard
        # tmuxPlugins.prefix-highlight
      ];
      shortcut = "a";  # Ctrl-a
      mouse = true;
      sensibleOnTop = true;
      extraConfig = ''
        # https://github.com/tmux/tmux/wiki/Clipboard#quick-summary
        # support
        set -g set-clipboard on
        set-option -sa terminal-features ',xterm-kitty:Clipboard'

        set -g @scroll-without-changing-pane "on"

        # Preserve window names from tmuxp
        set -g allow-rename off
        set -g automatic-rename off

        # split windows
        bind | split-window -h
        bind - split-window -v

        # hjkl pane traversal
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind-key V select-layout even-vertical
        bind-key H select-layout even-horizontal
        bind-key T select-layout tiled

        # TOD(pete): can't remember why I added this...especially here....
        # setenv -g PATH "$HOME/bin:$PATH"

        # clear screen
        bind C-l send-keys 'C-l'

        # Smart pane switching with awareness of Vim splits.
        # See: https://github.com/christoomey/vim-tmux-navigator

        vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +''\${vim_pattern}$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        bind-key -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l

        # Source local config if it exists
        if-shell "test -f ~/.config/tmux/tmux-local.conf" "source-file ~/.config/tmux/tmux-local.conf"
      '';
    };
    xdg.configFile."tmuxp/wheat-nix.yaml" = {
       source = ./tmuxp/wheat-nix.yaml;
    };
    xdg.configFile."tmuxp/opaque-systems.yaml" = {
       source = ./tmuxp/opaque-systems.yaml;
    };
    programs.zsh.envExtra = ''
      export DISABLE_AUTO_TITLE=true
    '';
    home.packages = with pkgs; [
      lsof  # TODO(pete): probably not neccessary, can't remember
      file  # TODO(pete): probably not neccessary, can't remember
      fzf
    ];
  };
}

