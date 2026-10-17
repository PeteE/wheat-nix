{
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
  home.stateVersion = "26.05";
}
