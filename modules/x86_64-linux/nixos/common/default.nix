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
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  environment.systemPackages = with pkgs; [
    dmidecode
    wget
    curl
    vim
    sops
    fasd
    zoxide
    xdotool
    #tmux-fingers
    neovim
    azure-storage-azcopy
    openbao
    usql
    presenterm
    kubectx
    asciinema
    cargo
    just
    postgresql_13
    oras
    git-credential-manager
    fd
    nodejs_22
    uv
    thumbs
    podman
    skopeo
    openssl
    # attic-server
    attic-client
    # clusterctl
    github-cli
    # mpv
    # clapper
    # nitrogen
    bc
    pinentry-rofi
    yazi
    niv
    nix-index
    devspace
    openvpn3
    lua5_3
    stylua
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
    lazygit
    nodePackages.eslint
    lua-language-server
    nixd
    rust-analyzer
    helm-ls
    yaml-language-server
    # python312Packages.jedi-language-server
    pyright
    kitty
  ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
  };

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
    # extraConfig = with pkgs; ''
    #   Defaults:picloud secure_path="${lib.makeBinPath [
    #     systemd
    #   ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    # '';
  };
}
