# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
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
    # firefox
    # docker
    # ipcalc
    # wireshark
    vim
    tree
    jq
  ];
}
