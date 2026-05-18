# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.kanidm;
in
{
  options.wheat.kanidm = {
    enable = mkEnableOption "Kanidm CLI client";

    serverUrl = mkOption {
      type = types.str;
      default = "https://idp.wheat-dn42.net";
      description = "URL of the Kanidm server";
    };

    verifyCa = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to verify the server's TLS certificate";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.kanidm_1_8 ];

    xdg.configFile."kanidm".text = ''
      uri = "${cfg.serverUrl}"
      verify_ca = ${if cfg.verifyCa then "true" else "false"}
    '';
  };
}
