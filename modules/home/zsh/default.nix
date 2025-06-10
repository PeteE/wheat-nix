# vim: ts=2:sw=2:et
{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    fasd
    zoxide
    # vimPlugins.zsh-histdb
  ];
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      # theme = "robbyrussell";
      theme = "powerlevel10k/powerlevel10k";
      custom = "$HOME/.oh-my-zsh/custom";
      plugins = [
        "aws"
        "vi-mode"
        "git"
        "rbw"
        "aliases"
        "aws"
        "azure"
        "common-aliases"
        "direnv"
        "docker"
        "dotenv"
        "emoji"
        "encode64"
        "extract"
        "zoxide"
        "fzf"
        "systemd"
        "nmap"
      ];
    };
    shellAliases = {
      vim = "nvim";
      ll = "ls -l";
      nos-update = "sudo nixos-rebuild switch";
      nos-list = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nos-delete = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system $@";
      k = "kubectl";
      gd = "git diff";
      gs = "git status";
      nd = "nix develop -c zsh";
    };
    plugins = [
        # {
        #   name = "zsh-histdb";
        # }

      # {
      #   name = "zsh-histdb";
      #   # src = pkgs.fetchFromGitHub {
      #   #   owner = "larkery";
      #   #   repo = "zsh-histdb";
      #   #   rev = "90a6c104d0fcc0410d665e148fa7da28c49684eb";
      #   #   hash = "sha256-vtG1poaRVbfb/wKPChk1WpPgDq+7udLqLfYfLqap4Vg=";
      #   # };
      # }
    ];
    enableCompletion = true;
    autocd = true;
    syntaxHighlighting = {
      enable = true;
    };
    initExtra = ''
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

      if [[ -f "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh" ]]; then
        source "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh"
      fi
      bindkey '^r' _histdb-isearch
      bindkey -M histdb-isearch '^[;' _histdb-isearch-cd
      #autoload -Uz add-zsh-hook
      #add-zsh-hook precmd histdb-update-outcome

      _zsh_autosuggest_strategy_histdb_top_here() {
          local query="select commands.argv from
      history left join commands on history.command_id = commands.rowid
      left join places on history.place_id = places.rowid
      where places.dir LIKE '$(sql_escape $PWD)%'
      and commands.argv LIKE '$(sql_escape $1)%'
      group by commands.argv order by count(*) desc limit 1"
          suggestion=$(_histdb_query "$query")
      }
      ZSH_AUTOSUGGEST_STRATEGY=histdb_top_here

      setopt nocorrectall
      setopt correct

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      export PATH=$HOME/bin:$PATH
      #export KUBECONFIG=$HOME/.config/sops-nix/secrets/kubeconfig-wheat
      export OPENAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/openaiApiKey)
      export ASSEMBLYAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/assemblyAiApiKey)
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $HOME/.config/sops-nix/secrets/peteeGptGithubToken)
      export OPAQUE_GITHUB_TOKEN=$(cat $HOME/.config/sops-nix/secrets/opaqueGithubToken)
      export JIRA_API_TOKEN=$(cat $HOME/.config/sops-nix/secrets/jira-api-token)
      export JIRA_USER=pete@opaque.co
      export JIRA_DOMAIN=opaque-systems.atlassian.net
      export AWS_PROFILE=wheat
      export AWS_DEFAULT_PROFILE=wheat
      export AWS_DEFAULT_REGION=us-east-1
      export AWS_SHARED_CREDENTIALS_FILE=$HOME/.config/sops-nix/secrets/aws-credentials
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit
      complete -C /etc/profiles/per-user/petee/bin/aws_completer aws
    '';
     envExtra = ''
       EDITOR=nvim
       AWS_CLI_AUTO_PROMPT=on
       PYTHONWARNINGS="ignore:Unverified HTTPS request"
     '';
  };
}
