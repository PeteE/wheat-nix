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
    user = {
      name = "pete";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3x/dtivaU+bPMRYzY1O+XQPEGnBahNnh9sBZMrJrIX petee"  # x1
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMShYQQ6RsCgYUXKxaVYjjGcjvdB533v/wsdrYq7G/7 JuiceSSH"  # phone
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjd2zJEmRiuqMJz2kC4ABIiSVE2HWdRPkZTmcAxp6GS petee@nixos" # nixos vm (ripper)
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1SMCMFF12YYwlYGIi/UATCPTQ+PEdYOygGFouYrd5N petee@m3p" # lappy
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Xr2ircu0B1j+fmj8r1P5xtRi+LstqeXCJ7XIdhpyI nixos@nixos" # rpi?
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMv8uBStPXcU4V5+7L6TpP08HhpG5vumutAFogVd0ca pete@m4" # litle mac
      ];
    };
    services.podman.enable = true;
  };

  # nix.linux-builder.enable = true;
  nix.settings.extra-substituters = [ "https://virby-nix-darwin.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "virby-nix-darwin.cachix.org-1:z9GiEZeBU5bEeoDQjyfHPMGPBaIQJOOvYOOjGMKIlLo="
  ];
  nix.settings.trusted-users = [ "root" "petee" "pete" ];

  services.virby = {
    debug = true;
    enable = false;
    cores = 8;
    rosetta = true;
    memory = "6GiB";
    diskSize = "100GiB";
    port = 31222;
    speedFactor = 1;
  };

  # hack to workaround nix group id changes
  ids.gids.nixbld = 350;
  system.stateVersion = 4;

}
