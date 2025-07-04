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
    comma.enable = true;
    desktop.enable = true;
    azure.enable = true;
    atuin.enable = true;
    carapace.enable = true;
    btop.enable = true;

    # TODO: only enable on m4, x1
    embedded.enable = true;
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    OLLAMA_HOST = "m4.porcupine-python.ts.net";
  };

  home.packages = with pkgs; [
    carapace
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
}
