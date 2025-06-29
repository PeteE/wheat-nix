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
  cfg = config.wheat.kitty;
in {
  options.wheat.kitty = {
    enable = mkEnableOption "Enable";
    themeFile = mkOption {
      default = "Catppuccin-Mocha";
      description = "kitty theme";
      type = types.str;
    };
    font = {
      name = mkOption {
        default = "Fira Code";
        description = "kitty font";
        type = types.str;
      };
      size = mkOption {
        default = 14.0;
        description = "kitty font size";
        type = types.float;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      font = {
        name = cfg.font.name;
        size = cfg.font.size;
      };
      themeFile = cfg.themeFile;
      settings = {
        cursor_shape = "underline";
        strip_trailing_spaces = "smart";
        copy_on_select = "yes";
        enable_audio_bell = "no";
        disable_ligatures = "cursor";
        cursor_blink_interval = 0;
        dynamic_background_opacity = "yes";
        background_opacity = "1.0";
      };
    };
    home.packages = with pkgs; [
      kitty
      kitty-themes
    ];
  };
}
