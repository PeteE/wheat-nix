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
  ...
}:
with lib;
let
  cfg = config.wheat.thermald;
in
{
  options.wheat.thermald = {
    enable = mkEnableOption "Enable";
  };

  config = mkIf cfg.enable {
    services.thermald.enable = true;
    environment.systemPackages = with pkgs; [
      lm_sensors
    ];
  };
}
