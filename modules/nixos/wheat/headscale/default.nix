{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat;
  inherit (lib) mkEnableOption mkIf;
in {
  options.wheat = {
    headscale = {
      enable = mkEnableOption "Enable";
    };
  };
  config = mkIf cfg.headscale.enable {
    services.headscale = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
