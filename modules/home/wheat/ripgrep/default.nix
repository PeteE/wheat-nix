# vim: ts=2:sw=2:et
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
    modulesPath,
    ...
}:
with lib; let
  cfg = config.wheat.ripgrep;
in {
  options.wheat.ripgrep = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--hidden"
      ];
    };
  };
}
