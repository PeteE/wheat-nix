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
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  wheat = {
    enable = true;
    user = {
      name = "azureuser";
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = [ "wheel" ];
    };
    sudo.enable = true;
    secrets.enable = true;
  };

  time.timeZone = "UTC";

  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    tcpdump
    zip
    unzip
    dig
    bat
    curl
    git
    git-credential-manager
    fd
    bc
    neovim
    tree
    unixtools.netstat
    htop
    sshguard
  ];
  nix.settings.trusted-users = [
    "root"
    "azureuser"
  ];
}
