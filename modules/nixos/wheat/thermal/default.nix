{
  config,
  pkgs,
  lib,
  ...
}:

services.thermald = {
 enable = true;
};

environment.systemPackages = [
  lm_sensors
];
