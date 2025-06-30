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
  cfg = config.wheat.nushell;
in {
  options.wheat.nushell = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nufmt
      skim
      nushell
    ];
    programs.nushell = {
      enable = true;
      plugins = with pkgs; [
        nushellPlugins.skim
        nushellPlugins.query
        nushellPlugins.polars
        nushellPlugins.highlight
        nushellPlugins.hcl
        nushellPlugins.units
        nushellPlugins.query
      ];
      settings = {
        edit_mode = "vi";
        buffer_editor = "nvim";
        history = {
          file_format = "sqlite";
          max_size = 10000000;
        };
        show_banner = false;
        completions = { };
      };
    };
  };
}
