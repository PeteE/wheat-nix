# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  inputs,
  namespace,
  format,
  virtual,
  host,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    fasd
    zoxide
    zsh-histdb
    zsh-fzf-tab
    fzf
    sqlite
    eza
    fd
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "argocd"
        "azure"
        "colored-man-pages"
        "vi-mode"
        "git"
        "gh"
        "kubectl"
        "helm"
        "aliases"
        "direnv"
        "encode64"
        "extract"
        "zoxide"
        "fzf"
        "systemd"
      ];
    };
    shellAliases = {
      c = "claude";
      arduino ="_JAVA_AWT_WM_NONREPARENTING=1 arduino";
      icat = "kitty +kitten icat";
      g = "git";
      tg = "terragrunt";
      ll = "ls -l";
      nos-update = "sudo nixos-rebuild switch --flake .#x1";
      nos-list = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nos-delete = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system $@";
      k = "kubectl";
      gd = "git diff";
      gdu = "git diff origin main";
      gs = "git status";
      nd = "nix develop -c zsh";
      vi = "nvim";
      vim = "nvim";
      j = "just";
      netshoot = "kubectl run netshoot --rm -it --image=nicolaka/netshoot --restart=Never -- bash";
    };
    enableCompletion = true;
    autocd = false;
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      setopt nocorrectall
      setopt correct

      # HIST_STAMPS="yyyy-mm-dd"
      # HISTIGNORE='\&:fg:bg:ls:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x:ls -l:ls -l'

      export PYTHONWARNINGS="ignore::FutureWarning"
      export PATH=$HOME/bin:$PATH

      # Disable pager for systemd tools (journalctl, systemctl, etc.)
      export SYSTEMD_PAGER=""

      # fzf-tab configuration (must be set before sourcing)
      # disable standard completion menu so fzf-tab can capture completions
      zstyle ':completion:*' menu no
      # use common prefix of completions as query, not the user input
      zstyle ':fzf-tab:*' query-string prefix
      # enable filename colorizing
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      # enable fzf-tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # source local zsh config for testing
      [[ -f ~/.config/zsh/zsh-local.zsh ]] && source ~/.config/zsh/zsh-local.zsh
    '';
  };
}
