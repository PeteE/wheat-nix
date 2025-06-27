# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    modulesPath,
    ...
}:
with lib; let
  cfg = config.wheat.ollama;
in {
  options.wheat.ollama = {
    enable = mkEnableOption "Enable";
    port = mkOption {
      default = 11434;
      type = types.ints.unsigned;
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.port;
      # acceleration = "cuda";
    };
    home.packages = [
      pkgs.ollama
    ];
  };
}
