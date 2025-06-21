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
  wheat = {
    enable = true;
    secrets.enable = true;
    user = {
      name = "Pete Erickson";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3x/dtivaU+bPMRYzY1O+XQPEGnBahNnh9sBZMrJrIX petee"  # x1
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaGYqqLKVikzCKsRJqfPu4zsTCKCfCz9xnWYQJNep+v petee@x1"  # prob dead
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMShYQQ6RsCgYUXKxaVYjjGcjvdB533v/wsdrYq7G/7 JuiceSSH"  # phone
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjd2zJEmRiuqMJz2kC4ABIiSVE2HWdRPkZTmcAxp6GS petee@nixos" # nixos vm (ripper)
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1SMCMFF12YYwlYGIi/UATCPTQ+PEdYOygGFouYrd5N petee@m3p" # lappy
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Xr2ircu0B1j+fmj8r1P5xtRi+LstqeXCJ7XIdhpyI nixos@nixos" # rpi?
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMv8uBStPXcU4V5+7L6TpP08HhpG5vumutAFogVd0ca pete@m4" # litle mac
      ];
    };
    # sudo.enable = true;
    # services.podman.enable = true;
  };

  # hack to workaround nix group id changes
  ids.gids.nixbld = 350;

  # services.nix-daemon.enable = true;
  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  nix.settings.trusted-users = [
     "@wheel"
     "root"
     "pete"
  ];
}
