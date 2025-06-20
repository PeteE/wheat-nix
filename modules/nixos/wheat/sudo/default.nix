{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.sudo;
in {
  options.wheat.sudo = with types; {
    enable = mkOption {
      type = bool;
      description = "Enable sudo";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
