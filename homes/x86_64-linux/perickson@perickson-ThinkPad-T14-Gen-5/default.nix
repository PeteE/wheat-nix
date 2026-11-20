{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{

  wheat = {
    rofi.enable = true;
    clipcat.enable = true;
    screenshot.enable = true;
    niri.enable = true;
    k9s.enable = true;
    kitty.enable = true;

    aws.enable = false;
    k8s.enable = lib.mkForce false;
    secrets.enable = lib.mkForce false;
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
  };

  targets.genericLinux = {
    enable = true;
    nixGL = {
      packages = inputs.nixgl.packages;
      defaultWrapper = "mesa";
    };
  };
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;

  home.stateVersion = "26.05";
}
