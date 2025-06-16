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
  # TODO(pete): should have a generic "screenshot" tool
  wheat.services.flameshot.enable = false;
  home.stateVersion = "25.11";
}
