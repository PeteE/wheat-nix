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
  cfg = config.wheat.zoxide;
in {
  options.wheat.zoxide = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--no-aliases"
      ];
    };
  };
}
