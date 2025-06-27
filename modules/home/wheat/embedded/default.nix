{
  lib,
  pkgs,
  inputs,
  namespace,
  format,
  virtual,
  host,
  config,
  ...
}:
with lib; let
  cfg = config.wheat.embedded;
in {
  options.wheat.embedded = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      platformio
    ];
  };
}

