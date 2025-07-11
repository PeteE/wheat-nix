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
  cfg = config.wheat.attic-client;
in {
  options.wheat.attic-client = with types; {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      attic-client
    ];
  };
}
