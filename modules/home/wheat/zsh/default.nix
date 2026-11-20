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
    zsh-histdb
    zsh-fzf-tab
    sqlite
    eza
    fd
  ];
  programs.direnv = { 
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fzf.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      weather = "curl https://wttr.in/";
      c = "claude";
      arduino = "_JAVA_AWT_WM_NONREPARENTING=1 arduino";
      icat = "kitty +kitten icat";
      g = "git";
      ll = "ls -l";
      nos-list = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nos-delete = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system $@";
      k = "kubectl";
      gd = "git diff";
      gdu = "git diff origin main";
      gs = "git status";
      nd = "nix develop -c zsh";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      pb = "pbcopy";
      j = "just";
      netshoot = "kubectl run netshoot --rm -it --image=nicolaka/netshoot --restart=Never -- bash";
      e64 = "base64";
      d64 = "base64 -d";
    }
    // lib.optionalAttrs config.wheat.secrets.enable {
      # Supermicro BMC of k8s-worker-200, e.g. `w200-ipmi power on`.
      # ipmitool -f reads the password from the decrypted sops file, so it's
      # never in the store, this config, the environment, or argv.
      w200-ipmi = "ipmitool -I lanplus -H 192.168.1.49 -U ADMIN -f ${config.sops.secrets.impi_password.path}";
    };
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    autocd = false;
    plugins =
      let omz = "${pkgs.oh-my-zsh}/share/oh-my-zsh"; in [
        { name = "omz-lib-git"; src = "${omz}/lib"; file = "git.zsh"; }
        { name = "git";     src = "${omz}/plugins/git";     file = "git.plugin.zsh"; }
        { name = "kubectl"; src = "${omz}/plugins/kubectl"; file = "kubectl.plugin.zsh"; }
    ];

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

  # BMC password for the w200-ipmi alias
  sops.secrets.impi_password = lib.mkIf config.wheat.secrets.enable { };
}
