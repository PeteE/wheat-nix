{
    lib,
    inputs,
    namespace,
    pkgs,
    stdenv,
    ...
}:
{
  programs.tmux = {
    enable = true;
    #tmuxp.enable = true;
    tmuxinator.enable = true;
    plugins = with pkgs; [
      { plugin = tmuxPlugins.tmux-fzf; }
      { plugin = tmuxPlugins.urlview; }
       { plugin = tmuxPlugins.fuzzback; }
      {
        plugin = tmuxPlugins.extrakto;
      }
      # {
      #   plugin = pkgs.thumbs;
      #   extraConfig = ''
      #     set -g @thumbs-key f
      #     run-shell ${pkgs.thumbs}/bin/tmux-thumbs
      #   '';
      # }
      # {
      #   plugin = mkTmuxPlugin {
      #     pluginName = "tmux-super-fingers";
      #     version = "unstable-2024-02-08";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "artemave";
      #       repo = "tmux_super_fingers";
      #       rev = "61e4ea226bceb6d6da738c7b2b4be069a7eb3cc7";
      #       sha256 = "sha256-oIAdQ8yOurYQ0KLiFLrppOKXe50s8UVEaSO+LyQbrhQ=";
      #     };
      #     installPhase = ''
      #       mkdir -p $out
      #       cp -r * $out/
      #     '';
      #     buildInputs = with pkgs; [
      #       python313
      #     ];

      #   };
      #   extraConfig = ''
      #     set -g @super-fingers-key f
      #     set -g @fingers-show-copied-notification 1
      #     set -g @fingers-main-action 'xsel -i -b'
      #   '';
      # }
      tmuxPlugins.yank
      tmuxPlugins.open
      tmuxPlugins.copycat
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.catppuccin
      {
          plugin = tmuxPlugins.continuum;
          #extraConfig = "set -g @continuum-boot-options 'kitty'";
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.session-wizard
      tmuxPlugins.prefix-highlight
    ];
    extraConfig = builtins.readFile ./tmux.conf;
  };
  xdg.configFile."tmuxinator/" = {
      source = ./tmuxinator;
  };
  home.packages = with pkgs; [
    lsof
    file
    thumbs
  ];
  programs.zsh.shellAliases.mux = "tmuxinator";
  # programs.zsh.initContent = ''
  #   source ${pkgs.tmuxinator}/share/zsh/site-functions/_tmuxinator
  # '';
}
