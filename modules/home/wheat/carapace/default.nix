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
  cfg = config.wheat.carapace;
in {
  options.wheat.carapace = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = if config.wheat.nushell.enable then true else false;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    home.packages = with pkgs; [
      carapace
    ];
  };
}
