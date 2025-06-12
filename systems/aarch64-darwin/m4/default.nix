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

  wheat = {   # modules/wheat/user
    defaults = {
      enable = true;
    };
    services.podman.enable = true;
    user = {
      enable = true;
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel" "NetworkManager"];
      extraOptions = {
        secrets = {
          enable = true;
        };
      };
    };
  };
}
