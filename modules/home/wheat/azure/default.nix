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
  cfg = config.wheat.azure;
in {
  options.wheat.azure = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      azure-cli
    ];
  };
}

