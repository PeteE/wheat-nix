{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.yazi;
in {
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
          chmod = yaziPlugins.chmod;
          git = yaziPlugins.git;
          glow = yaziPlugins.glow;
          diff = yaziPlugins.diff;
          mount = yaziPlugins.mount;
          bypass = yaziPlugins.bypass;
          starship = yaziPlugins.starship;
          wl-clipboard = yaziPlugins.wl-clipboard;
          yatline = yaziPlugins.yatline;
          yatline-catppuccin = yaziPlugins.yatline-catppuccin;
          relative-motions = yaziPlugins.relative-motions;
        };
        flavor = "catppuccin-mocha";
        keymap = {
          manager.prepened = [
            {
			  on = ["c" "m"];
			  run = "plugin chmod";
              esc = "Chmod on selected files";
            }
          ];
        };
      };
    };
  };
}
