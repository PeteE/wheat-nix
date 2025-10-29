{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.ai.claude-sessions;
in {
  options.wheat.ai.claude-sessions = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.wheat.claude-sessions
    ];
  };
}
