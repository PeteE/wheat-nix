{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.gcloud;
in {
  options.wheat.gcloud = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-cloud-sdk
    ];
  };
}
