# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.services.clickhouse;
in {
  options.wheat.services.clickhouse = {
    enable = mkEnableOption "enable";
  };
  config = mkIf cfg.enable {
    services.clickhouse.enable = true;

    # TODO: add more configs here
    # /etc/clickhouse-server/config.d
    environment.systemPackages = with pkgs; [
      clickhouse-cli
    ];
  };
}
