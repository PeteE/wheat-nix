{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  format, # A normalized name for the home target (eg. `home`).
  virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
  host, # The host name for this home.
  system,
  config,
  ...
}:
with lib; let
  cfg = config.wheat.aws;
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages."${system}";
in {
  options.wheat.aws = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs-stable; [
      awscli

    ];
    sops.secrets.aws-access-key-id = { };
    sops.secrets.aws-secret-access-key = { };

    programs.zsh = {
      envExtra = ''
        export AWS_ACCESS_KEY_ID=$(cat ${config.sops.secrets.aws-access-key-id.path})
        export AWS_SECRET_ACCESS_KEY=$(cat ${config.sops.secrets.aws-secret-access-key.path})
      '';
    };
  };
}
