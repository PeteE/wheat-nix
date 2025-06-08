{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # An instance of `pkgs` with your overlays and packages applied is also available.
    pkgs,
    # You also have access to your flake's inputs.
    inputs,

    # Additional metadata is provided by Snowfall Lib.
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    home, # The home architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this home (eg. `x86_64-home`).
    format, # A normalized name for the home target (eg. `home`).
    virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
    host, # The host name for this home.

    # All other arguments come from the home home.
    config,
    ...
}:
{
  imports = [
    ./nvim.nix
    ./kitty.nix
    ./zoxide.nix
    ./nvim.nix
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    kitty
    btop
    azure-storage-azcopy
    openbao
    usql
    links2
    presenterm
    kubectx
    asciinema
    cargo
    just
    # postgresql_13
    oras
    git-credential-manager
    fd
    nodejs_22
    uv
    thumbs
    # siege
    podman
    skopeo
    openssl
    attic-server
    attic-client
    clusterctl
    github-cli
    mpv
    clapper
    nitrogen
    bc
    pinentry-rofi
    yazi
    niv
    nix-index
    devspace
    openvpn3
    virtualenv
    lua5_3
    stylua
    mpd
    firefox
    kubectl
    kubernetes-helm
    docker
    yadm
    ipcalc
    wireshark
    yq-go
    glow
    aria2
    nix-output-monitor
  ];
  # my specific customizations
  wheat = {
    services = {
      flameshot = {
        enable = true;
      };
    };
  };
  home.stateVersion = "25.11";
}
