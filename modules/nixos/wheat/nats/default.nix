# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.services.nats;
in {
  options.wheat.services.nats = {
    enable = mkEnableOption "nats";
  };
  config = mkIf cfg.enable {
    services.nats = {
      enable = true;
      jetstream = true;
      settings = {
        jetstream = {
          max_mem = "1G";
          max_file = "10G";
        };
      };
    };
    environment.systemPackages = with pkgs; [
      natscli
    ];
  };
}
