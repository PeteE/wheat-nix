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
    git = {
      enable = true;
      openCommit = true;
    };
    tmux.enable = true;
    kitty.enable = true;
    nvim.enable = true;
    ripgrep.enable = true;
    secrets.enable = true;
    starship.enable = true;
    zoxide.enable = true;
    carapace.enable = true;
    btop.enable = true;
    k9s.enable = true;
    k8s.enable = true;
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    arduino
    mosquitto
    mqttx-cli
    zip
    unzip
    tailscale
    dig
    bat
    direnv
    curl
    wget
    nh
    git
    git-credential-manager
    fd
    bc
    yq-go
    tree
    unixtools.netstat
    htop
    gcc
  ];
}
