{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.hyprland;
in
{
  options.wheat.hyprland = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      wheat.catppuccin-hyprland
      hyprland-workspaces-tui
    ];
    xdg.configFile."hypr/catppuccin.conf" = {
      source = "${pkgs.wheat.catppuccin-hyprland}/themes/mocha.conf";
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    # home.pointerCursor = {
    #   package = pkgs.apple-cursor;
    #   name = "Apple Cursor";
    #   size = 24;

    #   hyprcursor = {
    #     enable = true;
    #     size = 18;
    #   };

    #   gtk.enable = true;
    # };

    xdg.configFile."hypr/hyprland.conf" = {
      text = import ./hyprland-config.nix {
        inherit pkgs;
      };
    };
    services.hyprsunset.enable = true;
    # programs.hyprshell = {
    #   enable = true;
    #   systemd.args = "-v";
    #   settings = {
    #     windows = {
    #       enable = true;
    #       items_per_row = 5;
    #       overview = {
    #         enable = true;
    #         key = "super_l";
    #         modifier = "alt";
    #         launcher = {
    #           width = 650;
    #           max_items = 5;
    #           default_terminal = "kitty";
    #           show_when_empty = true;
    #           plugins = {
    #             websearch = {
    #               enable = true;
    #               engines = [{
    #                 name = "DuckDuckGo";
    #                 url = "https://duckduckgo.com/?q=%s";
    #                 key = "d";
    #               }];
    #             };
    #             applications.enable = true;
    #             calc.enable = true;
    #             shell.enable = true;
    #             terminal.enable = true;
    #             path.enable = true;
    #           };
    #         };
    #       };
    #       switch = {
    #         enable = false;
    #         modifier = "alt";
    #         switch_workspaces = true;
    #       };
    #     };
    #   };
    #   styleFile = ./hyprshell-styles.css;
    # };
    programs.waybar = {
      enable = true;
      # style = "";
      settings = { };
      # systemd = {
      #   enable = false;
      #   target = "hyprland-session.target";
      # };
    };
  };
}

