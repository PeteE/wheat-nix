{
    home,
    pkgs,
    ...
}:
{
  wheat = {
    niri.enable = true;
    kitty.font.size = 14.0;  # For scale 1.0 on ultrawide
    ollama.enable = false;
    distrobox.enable = true;
    ai = {
      enable = true;
      ollamaHost = "192.168.1.115"; # m4
      mcp.enable = true;
      claude-sessions.enable = true;
      aichat.enable = true;
    };
    chromium.enable = true;
    misc.enable = true;
    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    firefox.enable = true;
    hyprland.enable = false;
    devenv.enable = true;
    zed-editor.enable = true;
    vscode.enable = true;
    azure.enable = true;
    aws.enable = true;
    dev-tools.enable = true;
    gcloud.enable = true;
    embedded.enable = true;
    attic-client.enable = true;
    signal.enable = true;
  };

  # notificaiton system
  services.mako = {
    enable = true;
    defaultTimeout = 5000;  # 5 seconds in milliseconds
  };

  # GTK theming (for thunar, etc.)
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
      };
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  programs.noctalia-shell = {
    enable = true;
  };
 
  home.stateVersion = "25.11";
}
