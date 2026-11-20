{
  lib,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.aws;
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages."${system}";
in
{
  options.wheat.aws = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs-stable; [
      awscli2

    ];
    sops.secrets.aws-env = { };

    programs.zsh.envExtra = ''
      [[ -r "${config.sops.secrets.aws-env.path}" ]] && source ${config.sops.secrets.aws-env.path}
    '';
  };
}
