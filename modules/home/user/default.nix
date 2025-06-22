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
    tmux.enable = true;
    kitty.enable = true;
    nushell.enable = true;
    nvim.enable = true;
    ripgrep.enable = true;
    secrets.enable = true;
    starship.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
    comma.enable = true;
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        logallrefupdates = true;
        ignorecase = true;
        precomposeunicde = true;
      };
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
    };
    userName = config.snowfallorg.user.name;
    userEmail = "pete.perickson@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };
  home.packages = with pkgs; [
    dig
    nushell
    btop
    # openbao
    # azure-storage-azcopy
    direnv
    curl
    wget
    git
    git-credential-manager
    usql
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
    # podman
    attic-client
    # yazi
    stylua
    yq-go
    glow
    # aria2
    # nix-output-monitor
    links2
    # presenterm
    # asciinema
    # attic-server
    # clusterctl
    # mpv
    # clapper
    # nitrogen
    # pinentry-rofi
    # niv
    # lua5_3
    firefox
    # docker
    # ipcalc
    # wireshark
    vim
    tree
    jq
  ];
}
