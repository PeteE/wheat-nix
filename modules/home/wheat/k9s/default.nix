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
  cfg = config.wheat.k9s;
in {
  # This module will contain any work-related stuff
  options.wheat.k9s = with types; {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      k9s
      kubectl
    ];
  };
}
