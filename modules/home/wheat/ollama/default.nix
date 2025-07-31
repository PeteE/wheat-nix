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
with lib; with types; let
  cfg = config.wheat.ollama;
in {
  options.wheat.ollama = {
    enable = mkEnableOption "Enable";
    port = mkOption {
      default = 11434;
      type = ints.unsigned;
    };
    listen = mkOption {
      default = "0.0.0.0";
      type = str;
    };
    models = mkOption {
      type = listOf str;
      default = [
        "qwen2.5-coder:latest"
        "gemma3:4b"
        "qwen:7b"
      ];
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = cfg.listen;
      port = cfg.port;
      # acceleration = "cuda";
    };
    home.packages = with pkgs; [
      ollama
    ];
  };
}
