# vim: ts=2:sw=2:et
{
  pkgs,
  inputs,
  system,
  config,
  lib,
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "m4" = {
        User = "pete";
      };
      "192.168.1.4" = {
        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedAlgorithms = "+ssh-rsa";
      };
    };
  };

  home.packages = with pkgs; [
    mosquitto
    mqttx-cli
    zip
    gnumake
    unzip
    dig
    bat
    ookla-speedtest
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
    pgcli
    jq
    fx
    pwgen
    python313Packages.json5
    gum
  ];
}
