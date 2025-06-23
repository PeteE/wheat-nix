{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.wifi;
  inherit (lib) mkEnableOption mkIf;
in {
  options.wheat.wifi = {
    enable = mkEnableOption "Enable wifi";
  };
  config = mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      networks = {
        soma20_5g = {
          pskRaw = "121e447798031c71665a2728c57099b937b3a66b84b0ce21acb6ed7983a823ae";
        };
        AA_zzz = {
          pskRaw = "0ca28caee11466a0f00e590972301f72a2deeb373d43a5534e77defeb4a60c6a";
        };
        "cabin-2.4Ghz" = {
          pskRaw = "cb033f2f917b9b87e57d9702e1bea4561a4ef145af6a1c2387ee51a4052b8666";
        };
      };
    };
  };
}
