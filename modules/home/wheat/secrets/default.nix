{
    lib,
    pkgs,
    inputs,
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    format, # A normalized name for the home target (eg. `home`).
    virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
    host, # The host name for this home.
    config,
    ...
}:
with lib; let
  cfg = config.wheat.secrets;
in {
  options.wheat.secrets = {
    enable = mkEnableOption "Enable custom sops secrets";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.sops ];
    sops.defaultSopsFile = ./main.yaml;
    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    sops.secrets.openaiApiKey = { };
    sops.secrets.assemblyAiApiKey = { };
    sops.secrets.peteeGptGithubToken = { };
    sops.secrets.opaqueGithubToken = { };
    sops.secrets.aws-credentials = { };
    sops.secrets.jira-api-token = { };
  };
}
