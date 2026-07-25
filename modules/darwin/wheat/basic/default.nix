# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat;
in
{
  options = {
    wheat = with types; {
      enable = mkEnableOption "Enable";
      secrets.enable = mkEnableOption "Enable SOPS secrets";
      user = with types; {
        name = mkOption {
          default = "pete";
          description = "Username to create";
          type = str;
        };
        authorizedKeys = mkOption {
          type = listOf str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3x/dtivaU+bPMRYzY1O+XQPEGnBahNnh9sBZMrJrIX petee" # x1
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaGYqqLKVikzCKsRJqfPu4zsTCKCfCz9xnWYQJNep+v petee@x1" # prob dead
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMShYQQ6RsCgYUXKxaVYjjGcjvdB533v/wsdrYq7G/7 JuiceSSH" # phone
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjd2zJEmRiuqMJz2kC4ABIiSVE2HWdRPkZTmcAxp6GS petee@nixos" # nixos vm (ripper)
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1SMCMFF12YYwlYGIi/UATCPTQ+PEdYOygGFouYrd5N petee@m3p" # lappy
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Xr2ircu0B1j+fmj8r1P5xtRi+LstqeXCJ7XIdhpyI nixos@nixos" # rpi?
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMv8uBStPXcU4V5+7L6TpP08HhpG5vumutAFogVd0ca pete@m4" # litle mac
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJPEHFE1Xt7Bh3fQeTTYDljVwvDoHO4hLYdOeEY0fYv0 root@m3p"
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.backupFileExtension = ".hm-backup";
    programs.zsh.enable = true;

    # Skip building the nix-darwin options manual. The options.json/manual
    # derivations force-evaluate every module (emitting unrelated deprecation
    # warnings) and embed the nixpkgs source path without proper context. We
    # don't use the on-disk darwin manual, so disable it. Mirrors the NixOS
    # `documentation.enable = false` in arm6/image.nix.
    documentation.enable = false;

    # Both Darwin hosts (m4, m3p) run Determinate Nix, which manages the Nix
    # installation with its own daemon. nix-darwin must not also manage Nix or
    # activation aborts ("Determinate detected, aborting activation"). Nix
    # settings are configured through Determinate (/etc/nix/nix.custom.conf),
    # not nix-darwin's nix.* options.
    nix.enable = false;

    # Set locale for UTF-8 support (needed for starship, tmux, etc.)
    environment.variables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
    users.groups.${cfg.user.name} = { };
    users.users.${cfg.user.name} = {
      inherit (cfg.user) name;
      home = "/Users/${cfg.user.name}";
      createHome = true;
      isHidden = false;
      shell = "${pkgs.zsh}/bin/zsh";
      openssh.authorizedKeys.keys = cfg.user.authorizedKeys;
    };

    services.openssh = {
      enable = true;
      extraConfig = ''
        GatewayPorts yes
        PasswordAuthentication no
        PermitRootLogin no
        PrintMotd no
        # StrictModes yes
        UseDns no
        # UsePAM yes
      '';
    };
    services.tailscale.enable = true;
    environment.systemPackages = with pkgs; [
      tailscale
    ];
    fonts.packages = with pkgs.nerd-fonts; [
      fira-code
      droid-sans-mono
      symbols-only
      jetbrains-mono
    ];
  };
}
