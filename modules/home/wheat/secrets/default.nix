{
    lib,
    pkgs,
    inputs,
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    format, # A normalized name for the home target (eg. `home`).
    virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
    host, # The host name for this home.
    config,
    system,
    ...
}:
with lib; let
  cfg = config.wheat.secrets;
  isDarwin = if lib.hasSuffix "darwin" system then true else false;
in {
  options.wheat.secrets = {
    enable = mkEnableOption "Enable custom sops secrets";
    defaultSopsFile  = mkOption {
      default = ./secrets.yaml;
      description = "SOPS encrypted file containing all secrets";
      type = types.path;
    };
    defaultSymlinkPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/sops-nix/secrets";
      description = ''
        Default place where the latest generation of decrypt secrets
        can be found.
      '';
    };
    defaultSecretsMountPoint = lib.mkOption {
      type = lib.types.str;
      default = "%r/secrets.d";
      description = ''
        Default place where generations of decrypted secrets are stored.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
      age
    ];
    sops.defaultSopsFile = cfg.defaultSopsFile;
    sops.age.keyFile = if isDarwin
      then "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
      else "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    sops.defaultSecretsMountPoint = cfg.defaultSecretsMountPoint;
    sops.defaultSymlinkPath = cfg.defaultSymlinkPath;

    # generic secrets: TODO(pete): refactor
    sops.secrets.headscale-api-key = { };
    programs.zsh = {
      envExtra = ''
        export HEADSCALE_CLI_API_KEY=$(cat ${config.sops.secrets.headscale-api-key.path})
      '';
    };
  };
}
