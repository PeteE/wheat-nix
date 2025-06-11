{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.defaults;
in {
  options.wheat.defaults = with types; {
    enable = mkEnableOption "Enable default settings";
  };

  config = mkIf cfg.enable {
    #  Common settings for all my nixos machines
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      btop
      openbao
      azure-storage-azcopy
      direnv
      curl
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
      podman
      attic-client
      yazi
      stylua
      yq-go
      glow
      aria2
      nix-output-monitor
      links2
      presenterm
      asciinema
      attic-server
      clusterctl
      mpv
      clapper
      nitrogen
      pinentry-rofi
      niv
      nix-index
      lua5_3
      firefox
      docker
      yadm
      ipcalc
      wireshark
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
    ];
  };
}
