{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat;
  inherit (lib) mkEnableOption mkOption mkIf;
in {
  options.wheat = {
    headscale = {
      enable = mkEnableOption "Enable";
    };
  };
  config = mkIf cfg.plasma.enable {
    # console.useXkbConfig = true;
    services.headscale = {
      enable = false;

    };
    # environment.systemPackages = with pkgs; [
    #   tailscale
    # ];
  };
}
