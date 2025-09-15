{ 
  inputs,
  pkgs,
  system,
  ... 
}:
{
  
  wheat = {
    ollama.enable = false;
    distrobox.enable = true;
    ai = {
      enable = true;
      ollamaHost = "192.168.1.115"; # m4
      mcp.enable = true;
      claude-sessions.enable = true;
      aichat.enable = false;
      opencommit.enable = false;
      ccr.enable = false;
    };

    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    # plasma.enable = false;
  };

  # TODO(pete) refactor all this
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprland-workspaces-tui
  ];
  xdg.configFile."hypr/hyprland.conf" = {
    text = import ./hyprland-config.nix {
      inherit pkgs;
    };
  };

  services.hyprsunset.enable = true;
  programs.hyprshell = {
    enable = true;
    systemd.args = "-v";
    settings = {
      windows = {
        enable = true;
        items_per_row = 5;
        overview = {
          enable = true;
          key = "super_l";
          modifier = "alt";
          launcher = {
            width = 650;
            max_items = 5;
            default_terminal = "kitty";
            show_when_empty = true;
            plugins = {
              websearch = {
                enable = true;
                engines = [{
                  name = "DuckDuckGo";
                  url = "https://duckduckgo.com/?q=%s";
                  key = "d";
                }];
              };
              applications.enable = true;
              calc.enable = true;
              shell.enable = true;
              terminal.enable = true;
              path.enable = true;
            };
          };
        };
        switch = {
          enable = false;
          modifier = "alt";
          switch_workspaces = true;
        };
      };
    };
    styleFile = ./hyprshell-styles.css;
  };
  programs.waybar = {
    enable = true;
    # style = "";
    settings = { };
    # systemd = {
    #   enable = false;
    #   target = "hyprland-session.target";
    # };
  };

  services.mako = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
