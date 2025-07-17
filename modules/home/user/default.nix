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
    tmux.enable = true;
    kitty.enable = true;
    nushell.enable = true;
    nvim.enable = true;
    ripgrep.enable = true;
    secrets.enable = true;
    starship.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
    azure.enable = true;
    carapace.enable = true;
    btop.enable = true;
    k9s.enable = true;
    attic-client.enable = true;
    firefox.enable = true;

    # TODO: only enable on m4, x1
    embedded.enable = true;
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    OLLAMA_HOST = "m4.porcupine-python.ts.net";
  };

  home.packages = with pkgs; [
    bat
    claude-code
    ollama
    tailscale
    dig
    openbao
    direnv
    curl
    wget
    nh
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
    # yazi
    # stylua
    yq-go
    glow
    links2
    presenterm
    asciinema
    # clusterctl
    # mpv
    # clapper
    # nitrogen
    # lua5_3
    vim
    tree
    jq
    slack
    slack-term
    delve
  ];
}
