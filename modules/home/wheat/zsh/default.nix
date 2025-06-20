# vim: ts=2:sw=2:et
{ pkgs, config, ... }:
{
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;
  home.packages = with pkgs; [
    fasd
    zoxide
    zsh-histdb
    fzf
    sqlite
    # zsh-powerlevel10k
    github-cli
    awscli2
    direnv
    kubectx
    kubectl
  ];
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      # theme = "";
      # custom = "$HOME/.oh-my-zsh/custom";
      plugins = [
        "aws"
        "argocd"
        "azure"
        "colored-man-pages"
        "vi-mode"
        "git"
        "gh"
        "kubectl"
        "kubectx"
        "helm"
        "aliases"
        "common-aliases"
        "direnv"
        "docker"
        "docker-compose"
        "dotenv"
        "emoji"
        "encode64"
        "extract"
        "zoxide"
        "fzf"
        # "systemd"
        # "nmap"
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
    };
    plugins = [
      {
        name = "zsh-histdb";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "90a6c104d0fcc0410d665e148fa7da28c49684eb";
          hash = "sha256-vtG1poaRVbfb/wKPChk1WpPgDq+7udLqLfYfLqap4Vg=";
        };
      }
    ];
    enableCompletion = true;
    autocd = true;
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      # export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      # source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      ENABLE_CORRECTION="true"
      COMPLETION_WAITING_DOTS="true"
      HIST_STAMPS="yyyy-mm-dd"

      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      HISTIGNORE='\&:fg:bg:ls:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x:ls -l:ls -l'

      if [[ -f "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh" ]]; then
        source "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh"
      fi

      bindkey '^r' _histdb-isearch
      bindkey -M histdb-isearch '^[;' _histdb-isearch-cd

      _zsh_autosuggest_strategy_histdb_top_here() {
        local query="SELECT commands.argv FROM
          history LEFT JOIN commands ON history.command_id = commands.rowid
          LEFT JOIN places ON history.place_id = places.rowid
          WHERE places.dir LIKE '$(sql_escape $PWD)%'
          AND commands.argv LIKE '$(sql_escape $1)%'
          GROUP BY commands.argv ORDER BY count(*) DESC LIMIT 1"

        suggestion=$(_histdb_query "$query")
      }
      ZSH_AUTOSUGGEST_STRATEGY=histdb_top_here

      setopt nocorrectall
      setopt correct

      export PATH=$HOME/bin:$PATH
      export OPENAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/openaiApiKey)
      export ASSEMBLYAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/assemblyAiApiKey)
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $HOME/.config/sops-nix/secrets/peteeGptGithubToken)
      export OPAQUE_GITHUB_TOKEN=$(cat $HOME/.config/sops-nix/secrets/opaqueGithubToken)
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit
    '';
     envExtra = ''
       EDITOR=${pkgs.neovim}/bin/nvim

     '';
  };
}
