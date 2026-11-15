{
  lib,
  home,
  ...
}:
{
  # Headless hypervisor: no secrets (no age key on this host), keep it lean
  wheat = {
    embedded.enable = false;
    secrets.enable = lib.mkForce false;
    aws.enable = false;
    tor.enable = false;
  };
  catppuccin.enable = lib.mkForce false;
  home.stateVersion = "26.05";
}
