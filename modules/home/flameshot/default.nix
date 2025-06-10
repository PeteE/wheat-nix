{
    lib,
    pkgs,
    inputs,
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    format, # A normalized name for the home target (eg. `home`).
    virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
    host, # The host name for this home.
    config,
    ...
}:
with lib; let
  cfg = config.wheat.services.flameshot;
in {
  options.wheat.services.flameshot = {
    enable = mkEnableOption "Enable flameshot";
  };

  config = mkIf cfg.enable {
    services.flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = false;
          showStartupLaunchMessage = false;
        };
      };
    };
  };
}
