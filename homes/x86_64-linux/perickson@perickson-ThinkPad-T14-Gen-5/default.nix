{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.niri.homeModules.niri ];

  wheat = {
    rofi.enable = true;
    clipcat.enable = true;
    screenshot.enable = true;
    niri = {
      enable = true;
      # package = config.lib.nixGL.wrap pkgs.niri-stable;
      outputs = {
        "eDP-1".scale = 1.0;
        # "DP-1" = {
        #   scale = 1.0;
        #   mode = { width = 3440; height = 1440; refresh = 100.0; };
        #   position = { x = 0; y = 0; };
        # };
      };
    };
    k9s.enable = true;
    kitty.enable = true;

    aws.enable = false;
    k8s.enable = lib.mkForce false;
    secrets.enable = lib.mkForce false;
  };
  home.packages = [
    (pkgs.writeShellScriptBin "niri-nix-session" ''
      # GDM doesn't load your Nix profile, so load it here
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      ${config.programs.niri.package}/bin/niri --session
      systemctl --user stop niri-session.target
    ''
    )
  ];
  home.pointerCursor.enable = true;
  catppuccin = {
    flavor = "mocha";   # latte | frappe | macchiato | mocha
    accent = "mauve";   # blue, lavender, pink, ...
    cursors.enable = true;
  };
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";   # for GTK3 apps that ignore color-scheme
  };
  xdg.configFile."xdg-desktop-portal/niriri-portals.conf".text = ''
    [preferred]
    default=gnome;gtk
    org.freedesktop.impl.portal.Access=gtk
    org.freedesktop.impl.portal.Notification=gtk
  '';
  systemd.user.targets.niri-session.Unit = {
    Description = "niri compositor session";
    BindsTo = [ "graphical-session.target" ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  # notificaiton system
  services.mako = {
    enable = true;
    settings.default-timeout = 5000; # 5 seconds in milliseconds
    extraConfig = ''
      [app-name=Slack]
      default-timeout=3000
    '';
  };

  programs.noctalia = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.noctalia;
  };

  targets.genericLinux = {
    enable = true;
    nixGL = {
      packages = inputs.nixgl.packages;
      defaultWrapper = "mesa";
    };
  };
  programs.kitty = {
    package = config.lib.nixGL.wrap pkgs.kitty;
    settings.shell = "${config.programs.zsh.package}/bin/zsh";
  };

  home.stateVersion = "26.05";
}
