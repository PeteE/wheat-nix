# vim: ts=2:sw=2:et
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
      secrets.enable = mkEnableOption "Enable SOPS secrets";
      user = with types; {
        name = mkOption {
          default = "petee";
          description = "Username to create";
          type = str;
        };
        authorizedKeys = mkOption {
          type = listOf str;
          default = [
            # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMv8uBStPXcU4V5+7L6TpP08HhpG5vumutAFogVd0ca pete@m4" # litle mac
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    users.groups.${cfg.user.name} = {};
    users.users.${cfg.user.name} = {
      inherit (cfg.user) name;
      home = "/home/${cfg.user.name}";
      createHome = true;
      isHidden = false;
      shell = pkgs.zsh;
      uid = 1000;
      openssh.authorizedKeys.keys = cfg.user.authorizedKeys;
    };

    services.openssh = {
      enable = true;
      extraConfig = ''
        # GatewayPorts no
        PasswordAuthentication yes
        PermitRootLogin no
        # PrintMotd no
        # StrictModes yes
        # UseDns yes
        # UsePAM yes
      '';
    };

    # TODO: waaaay too much; refactor
    environment.systemPackages = with pkgs; [
      dig
      nushell
      # btop
      # openbao
      # azure-storage-azcopy
      # direnv
      # curl
      # wget
      git
      git-credential-manager
      # usql
      # kubectx
      # kubectl
      # kubernetes-helm
      # tcpdump
      # oras
      # nodejs_22
      # uv
      # just
      # postgresql_15
      # cargo
      # fd
      # skopeo
      # openssl
      # github-cli
      # bc
      # podman
      # attic-client
      # yazi
      # stylua
      # yq-go
      # glow
      # aria2
      # nix-output-monitor
      # links2
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
      # yadm
      # ipcalc
      # wireshark
      # vim
      # tree
      # jq
    ];
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
    services.tailscale.enable = true;
  };
}
