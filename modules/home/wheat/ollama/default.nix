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
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      environmentVariables = {
      };
    };
    home.packages = with pkgs; [
      ollama
    ];
  };
}
