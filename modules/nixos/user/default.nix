{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.user;
in {
  options.wheat.user = with types; {
    name = mkOption {
      default = "petee";
      description = "Username for nixos user";
      type = str;
    };
    hashedPassword = mkOption {
      description = "hash password";
      type = str;
    };
    extraGroups = mkOption {
      default = ["wheel" "NetworkManager"];
      description = "Additional groups to add the user to.";
      type = listOf str;
    };
    extraOptions = mkOption {
      default = { };
      description = "Options to pass directly to home-manager.";
      type = attrs;
    };
    authorizedKeys = mkOption {
      type = listOf str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3x/dtivaU+bPMRYzY1O+XQPEGnBahNnh9sBZMrJrIX petee"
      ];
    };
  };
  config = {
    programs.zsh.enable = true;
    users.groups.${cfg.name} = {};
    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) extraGroups name hashedPassword;
      home = "/home/${cfg.name}";
      shell = pkgs.zsh;
      uid = 1000;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
