# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.signal;
in {
  options.wheat.signal = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}

