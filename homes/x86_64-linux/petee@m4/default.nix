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
    config,
    ...
}:
{
  # The only customizations here should be setting values that apply to this specific combination of x86_64 on a hostname called `m4`.
  # In other words, these should be pretty much empty
  home.stateVersion = "25.11";
}
