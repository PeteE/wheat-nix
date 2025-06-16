{
    lib,
    pkgs,
    inputs,
    namespace,
    home,
    target,
    format,
    virtual,
    host,
    # All other arguments come from the home home.
    config,
    ...
}:
{
  # The only customizations here should be setting values that apply to this specific combination of x86_64 on a hostname called `x1`.
  # In other words, these should be pretty much empty
  wheat = {
    secrets.enable = true;
    services = {
      flameshot = {
        enable = true;
      };
    };
    nushell.enable = true;
  };
  home.stateVersion = "25.11";
}
