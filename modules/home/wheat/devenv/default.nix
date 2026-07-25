{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.devenv;
in
{
  options.wheat.devenv = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];
  };
}
