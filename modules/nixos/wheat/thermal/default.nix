{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.thermald = {
   enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
