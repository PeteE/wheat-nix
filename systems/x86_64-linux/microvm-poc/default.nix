# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    modulesPath,
    ...
}:
{
  microvm.hypervisor = "cloud-hypervisor";
  time.timeZone = "America/Chicago";
  system.stateVersion = "25.11";
}
