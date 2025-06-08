{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # You also have access to your flake's inputs.
    inputs,

    # The namespace used for your flake, defaulting to "internal" if not set.
    namespace,

    # All other arguments come from NixPkgs. You can use `pkgs` to pull packages or helpers
    # programmatically or you may add the named attributes as arguments here.
    pkgs,
    stdenv,
    ...
}:
{
  programs.tmux = {
    enable = true;
    #tmuxp.enable = true;
    tmuxinator.enable = true;
    plugins = with pkgs.tmuxPlugins; [
        # {
        #   plugin = pkgs.tmuxPlugins.tmux-super-fingers;
        #   extraConfig = ''
        #     set -g @super-fingers-key f
        #     set -g @fingers-show-copied-notification 1
        #     set -g @fingers-main-action 'xsel -i -b'
        #   '';
        # }
        { plugin = pkgs.tmuxPlugins.tmux-fzf; }
        { plugin = pkgs.tmuxPlugins.urlview; }
        # { plugin = fuzzback; }
        {
          plugin = pkgs.tmuxPlugins.extrakto;
        }
        {
            plugin = pkgs.tmuxPlugins.tmux-thumbs;
            extraConfig = ''
              set -g @thumbs-key f
            '';
        }
        pkgs.tmuxPlugins.yank
        pkgs.tmuxPlugins.open
        pkgs.tmuxPlugins.copycat
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.resurrect
        pkgs.tmuxPlugins.catppuccin
        {
            plugin = pkgs.tmuxPlugins.continuum;
            #extraConfig = "set -g @continuum-boot-options 'kitty'";
        }
        pkgs.tmuxPlugins.better-mouse-mode
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.session-wizard
        pkgs.tmuxPlugins.prefix-highlight
    ];
    extraConfig = builtins.readFile ./tmux.conf;
  };
  xdg.configFile."tmuxinator/" = {
      source = ./tmuxinator;
  };
  programs.zsh.shellAliases.mux = "tmuxinator";
  programs.zsh.initExtraBeforeCompInit = ''
    source ${pkgs.tmuxinator}/share/zsh/site-functions/_tmuxinator
  '';
}
