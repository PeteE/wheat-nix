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
  # services.nix-daemon.enable = true;
  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  nix.settings.trusted-users = [
    "@wheel"
    "root"
    "pete"
  ];

  wheat = {
    services.podman.enable = true;
    # defaults = {
    #   enable = true;
    # };
    # user = {
    #   hashedPassword = "$y$j9T$1b15FYbtNYo9cbuBDHes20$tGi2k75oJhgl6WKk/1RbsHtze3tFcHCABFASri7Hds9";
    #   extraGroups = ["wheel"];
    #   extraOptions = {
    #     secrets = {
    #       enable = true;
    #     };
    #   };
    # };
  };
}

