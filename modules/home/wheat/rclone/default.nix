{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wheat.rclone;
in
{
  options.wheat.rclone = {
    enable = mkEnableOption "Enable rclone with Google Photos client credentials from sops";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];

    sops.secrets."rclone/client_id" = { };
    sops.secrets."rclone/client_secret" = { };

    programs.zsh.envExtra = ''
      export RCLONE_CONFIG_GPHOTOS_CLIENT_ID="$(cat ${config.sops.secrets."rclone/client_id".path})"
      export RCLONE_CONFIG_GPHOTOS_CLIENT_SECRET="$(cat ${config.sops.secrets."rclone/client_secret".path})"
    '';
  };
}
