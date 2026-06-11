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
with lib;
let
  cfg = config.wheat.carapace;
in
{
  options.wheat.carapace = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = false;
      enableZshIntegration = true;
    };
  };
}
