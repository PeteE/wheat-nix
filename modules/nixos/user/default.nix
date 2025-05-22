{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.user;
in {
  options.wheat.user = with types; {
    name = mkOption {
      default = config.snowfallorg.user.name;
      description = "The user account to create";
      type = listOf str
    };
    extraGroups = mkOption {
      default = ["wheel", "NetworkManager"];
      description = "Additional groups to add the user to.";
      type = listOf str;
    };
    extraOptions = mkOption {
      default = { };
      description = "Options to pass directly to home-manager.";
      type = attrs;
  };

  config = {
    users.users.${cfg.name} =
      {
        isNormalUser = true;
        inherit (cfg) name;
        # inherit (cfg) extraGroups name;
        home = "/home/${cfg.name}";
        group = cfg.name;
        shell = pkgs.zsh;
        hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
        uid = 1000;
      }
      // cfg.extraOptions;
  };
}
