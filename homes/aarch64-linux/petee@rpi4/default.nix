{
  lib,
  home,
  ...
}:
{
  wheat = {
    embedded.enable = false;
    secrets.enable = true;
    aws.enable = true;
    tor.enable = false;
  };
  # catppuccin/nix builds whiskers (Rust) from source; not cached and slow on the Pi
  catppuccin.enable = lib.mkForce false;
  home.stateVersion = "26.05";
}
