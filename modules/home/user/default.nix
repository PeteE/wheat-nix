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
    ...
}:
{
  home = {
    username = config.snowfallorg.user.name;
  };
  wheat = {
    tmux.enable = false;
    kitty.enable = true;
    nushell.enable = true;
    nvim.enable = true;
    ripgrep.enable = true;
    secrets.enable = true;
    starship.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
    comma.enable = true;
    desktop.enable = true;
    azure.enable = true;
    atuin.enable = true;

    # TODO: only enable on m4, x1
    embedded.enable = true;
    btop.enable = true;
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    OLLAMA_HOST = "m4.porcupine-python.ts.net";
  };

  home.packages = with pkgs; [
    ollama
    tailscale
    dig
    openbao
    direnv
    curl
    wget
    git
    git-credential-manager
    usql
    podman
    kubectx
    kubectl
    kubernetes-helm
    tcpdump
    oras
    nodejs_22
    uv
    just
    postgresql_15
    cargo
    fd
    skopeo
    openssl
    github-cli
    bc
    attic-client
    # yazi
    # stylua
    yq-go
    glow
    links2
    presenterm
    asciinema
    # attic-server
    # clusterctl
    # mpv
    # clapper
    # nitrogen
    # lua5_3
    firefox
    vim
    tree
    jq
  ];
  programs.tmux = {
    enable = true;
    # shell = "${pkgs.zsh}/bin/zsh";
    shell = "/bin/zsh";
    # terminal = "xterm-kitty";
    # terminal = "xterm-256color";
    secureSocket = false;
    historyLimit = 100000;
    keyMode = "vi";
    # tmuxp.enable = true;
    # tmuxinator.enable = true;

    # plugins = with pkgs; [
    #   { plugin = tmuxPlugins.tmux-fzf; }
    #   { plugin = tmuxPlugins.urlview; }
    #   { plugin = tmuxPlugins.fuzzback; }
    #   { plugin = tmuxPlugins.extrakto; }
    #   tmuxPlugins.yank
    #   tmuxPlugins.open
    #   tmuxPlugins.copycat
    #   tmuxPlugins.sensible
    #   {
    #     plugin = tmuxPlugins.resurrect;
    #     extraConfig = ''
    #       # defaults
    #       # set -g @resurrect-save 's'
    #       # set -g @resurrect-restore 'r'
    #     '';
    #   }
    #   {
    #     plugin = tmuxPlugins.catppuccin;
    #     extraConfig = ''
    #       set -g @catppuccin_flavor 'mocha'
    #       set -g @catppuccin_window_status_style "rounded"
    #     '';
    #   }
    #   tmuxPlugins.better-mouse-mode
    #   tmuxPlugins.vim-tmux-navigator
    #   # tmuxPlugins.session-wizard
    #   # tmuxPlugins.prefix-highlight
    # ];
    shortcut = "a";  # Ctrl-a
    mouse = true;
    newSession = true;
    sensibleOnTop = true;
    # extraConfig = ''
    #   set -g set-clipboard on
    #   set -g @scroll-without-changing-pane "on"

    #   # split windows
    #   bind | split-window -h
    #   bind - split-window -v

    #   # hjkl pane traversal
    #   bind h select-pane -L
    #   bind j select-pane -D
    #   bind k select-pane -U
    #   bind l select-pane -R

    #   # clear screen
    #   bind C-l send-keys 'C-l'

    #   bind-key V select-layout even-vertical
    #   bind-key H select-layout even-horizontal
    #   bind-key T select-layout tiled

    #   set -g status-right-length 100
    #   set -g status-left-length 100
    #   set -g status-left ""
    #   set -g status-right "#{E:@catppuccin_status_application}"
    #   set -agF status-right "#{E:@catppuccin_status_cpu}"
    #   set -ag status-right "#{E:@catppuccin_status_session}"
    #   set -ag status-right "#{E:@catppuccin_status_uptime}"
    #   set -agF status-right "#{E:@catppuccin_status_battery}"
    # '';
    # builtins.readFile ./tmux.conf;
  };
}
