{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.ai.ccr;
  ccr = import ./package.nix {};
in {
  options.wheat.ai.ccr = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = [
      ccr
    ];
  };
}
