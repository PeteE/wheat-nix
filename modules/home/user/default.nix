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

  # Lets the already-configured catppuccin.gtk.icon settings (Papirus-Dark,
  # mocha/mauve) actually get written and applied. Papirus-folders is Linux-only.
  gtk.enable = !pkgs.stdenv.hostPlatform.isDarwin;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "m4 m4-wired m4-wifi petee-m4.porcupine-python.ts.net 192.168.1.149" = {
        User = "pete";
      };
      # Pin LAN IPs so ssh skips name resolution: Tailscale MagicDNS (search
      # domain) answers NXDOMAIN for these and can beat /etc/hosts on macOS.
      "m4-wired" = {
        HostName = "192.168.1.149";
      };
      "m4-wifi" = {
        HostName = "192.168.1.115";
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
    deploy-rs # cached nixpkgs build; flake input only supplies lib.activate (see lib/deploy-pkgs.nix)
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
