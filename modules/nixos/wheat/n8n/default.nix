{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.services.n8n;
  inherit (lib) mkEnableOption mkOption mkIf;
in {
  options.wheat.services.n8n = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    services.n8n = {
      enable = true;
      openFirewall = true;
    };
    environment.systemPackages = with pkgs; [
      n8n-task-runner-launcher
    ];
  };
}

