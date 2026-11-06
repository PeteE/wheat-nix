{
  lib,
  home,
  ...
}:
{
  wheat = {
    # platformio/arduino/meshtastic aren't cached for aarch64; building them
    # (incl. duckdb via meshtastic -> narwhals tests) overwhelms the Pi
    embedded.enable = false;
    secrets.enable = true;
    aws.enable = true;
    tor.enable = true;
  };
  # catppuccin/nix builds whiskers (Rust) from source; not cached and slow on the Pi
  catppuccin.enable = lib.mkForce false;
  home.stateVersion = "26.05";
}
