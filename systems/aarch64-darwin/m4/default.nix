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
     ../../../modules/shared/wheat/default.nix
 ];

 # hack to workaround nix group id chnages
 # only neccessary on this single box.
 ids.gids.nixbld = 350;

  # services.nix-daemon.enable = true;
  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  nix.settings.trusted-users = [
    "@wheel"
    "root"
    "pete"
  ];
  wheat = {
    enable = false;
    secrets.enable = true;
    services.podman.enable = true;
    user = {
      hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
      extraGroups = ["wheel"];
    };
  };
}
