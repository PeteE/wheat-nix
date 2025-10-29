# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.services.redis;
in {
  options.wheat.services.redis = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    services.redis.servers."default" = {
      enable = true;
      openFirewall = false;
      bind = "0.0.0.0";  # all interfaces
      port = 6379;
      logLevel = "notice";
      syslog = true;
      # requirePass = "SuperSecret";

      # TODO(pete): eviction policy
      settings = { };
    };
  };
}

