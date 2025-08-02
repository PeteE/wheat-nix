{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.entertainment;
in {
  options.wheat.entertainment = with types; {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.spotify-player = {
      enable = true;
    };
  };
}
