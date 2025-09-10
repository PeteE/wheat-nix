# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.choose-gui;
in {
  options.wheat.choose-gui = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      choose-gui
    ];
  };
}
