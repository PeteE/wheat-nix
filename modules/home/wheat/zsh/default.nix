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
    nmap
    fzf
    sqlite
  ];
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      # theme = "";
      # custom = "$HOME/.oh-my-zsh/custom";
      plugins = [
        # "aws"
        "argocd"
        "azure"
        "colored-man-pages"
        "vi-mode"
        "git"
        "gh"
        "kubectl"
        "helm"
        "aliases"
        "common-aliases"
        "direnv"
        # "docker"
        # "docker-compose"
        # "dotenv"
        # "emoji"      ONE of these 3 is slow
        "encode64"
        "extract"
        "zoxide"
        "fzf"
        "systemd"
        "nmap"
      ];
    };
    shellAliases = {
      ll = "ls -l";
      nos-update = "sudo nixos-rebuild switch --flake .#x1";
      nos-list = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nos-delete = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system $@";
      k = "kubectl";
      gd = "git diff";
      gs = "git status";
      nd = "nix develop -c zsh";
      vi = "nvim";
      vim = "nvim";
    };
    enableCompletion = true;
    autocd = false;
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      setopt nocorrectall
      setopt correct

      # ENABLE_CORRECTION="true"
      # COMPLETION_WAITING_DOTS="true"
      HIST_STAMPS="yyyy-mm-dd"
      HISTIGNORE='\&:fg:bg:ls:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x:ls -l:ls -l'

      # # TODO fix secrets
      export PATH=$HOME/bin:$PATH
      # export OPENAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/openaiApiKey)
      # export ASSEMBLYAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/assemblyAiApiKey)
      # export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $HOME/.config/sops-nix/secrets/peteeGptGithubToken)
      # export OPAQUE_GITHUB_TOKEN=$(cat $HOME/.config/sops-nix/secrets/opaqueGithubToken)
    '';
     envExtra = ''
       EDITOR=${pkgs.neovim}/bin/nvim
     '';
  };
}
