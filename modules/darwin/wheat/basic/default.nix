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
      # secrets.enable = mkEnableOption "Enable SOPS secrets";
      user = with types; {
        name = mkOption {
          default = "pete";
          description = "Username to create";
          type = str;
        };
        authorizedKeys = mkOption {
          type = listOf str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3x/dtivaU+bPMRYzY1O+XQPEGnBahNnh9sBZMrJrIX petee"  # x1
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaGYqqLKVikzCKsRJqfPu4zsTCKCfCz9xnWYQJNep+v petee@x1"  # prob dead
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMShYQQ6RsCgYUXKxaVYjjGcjvdB533v/wsdrYq7G/7 JuiceSSH"  # phone
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjd2zJEmRiuqMJz2kC4ABIiSVE2HWdRPkZTmcAxp6GS petee@nixos" # nixos vm (ripper)
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1SMCMFF12YYwlYGIi/UATCPTQ+PEdYOygGFouYrd5N petee@m3p" # lappy
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Xr2ircu0B1j+fmj8r1P5xtRi+LstqeXCJ7XIdhpyI nixos@nixos" # rpi?
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMv8uBStPXcU4V5+7L6TpP08HhpG5vumutAFogVd0ca pete@m4" # litle mac
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.backupFileExtension = "hm-backup";
    programs.zsh.enable = true;
    users.groups.${cfg.user.name} = {};
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
    fonts.packages = with pkgs.nerd-fonts; [
      fira-code
      droid-sans-mono
      symbols-only
      jetbrains-mono
    ];
  };
}
