{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.yazi;
in
{
  options.wheat.yazi = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
        plugins = with pkgs; {
          inherit (yaziPlugins) chmod;
          inherit (yaziPlugins) git;
          inherit (yaziPlugins) glow;
          inherit (yaziPlugins) diff;
          inherit (yaziPlugins) mount;
          inherit (yaziPlugins) bypass;
          inherit (yaziPlugins) starship;
          inherit (yaziPlugins) wl-clipboard;
          inherit (yaziPlugins) yatline;
          inherit (yaziPlugins) yatline-catppuccin;
          inherit (yaziPlugins) relative-motions;
        };
        flavor = "catppuccin-mocha";
        keymap = {
          manager.prepened = [
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
              esc = "Chmod on selected files";
            }
          ];
        };
      };
    };
  };
}
