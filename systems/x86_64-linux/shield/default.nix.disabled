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
let
  username = "opadmin";
in {
  imports =
    [
      (../../../modules/shared/wheat/default.nix)
    ];

  networking.hostName = "shield";
  users.users."${username}" = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "Admin User";
    openssh.authorizedKeys.keys = [ ./ssh/id_ed25519.pub ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # test user doesn't have a password
  services.openssh.settings.PasswordAuthentication = false;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    file
    htop
    wget
    curl
  ];
  nix.settings.trusted-users = [ username ];
}
