{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat;
in {
  options = {
    wheat = with types; {
      enable = mkEnableOption "Enable";
      user.hashedPassword = mkOption {
        type = types.str;
        description = "The hashed password for the user.";
      };
      user.extraGroups = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional groups for the user.";
      };
      user.extraOptions.secrets.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable secrets for the user.";
      };
    };
  };

  config = mkIf cfg.enable {
    #  Common settings for all my nixos machines
    # services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      btop
      openbao
      azure-storage-azcopy
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
      vim
      tree
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
    ];
  };
}
