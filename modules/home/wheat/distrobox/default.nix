
{
  lib,
  pkgs,
  inputs,
  namespace,
  format,
  virtual,
  host,
  config,
  ...
}:
with lib; let
  cfg = config.wheat.distrobox;
in {
  options.wheat.distrobox = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.distrobox = {
      enable = true;
      # containers = {
      #   common-debian = {
      #     image = "ubuntu:jammy";
      #     entry = true;
      #     # additional_packages = "git";
      #     # init_hooks = [
      #     #   "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
      #     #   "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
      #     # ];
      #   };
      # };
    };
    xdg.configFile."containers/registries.conf" = {
      text = ''
        unqualified-search-registries = ["docker.io"]
      '';
    };
    xdg.configFile."containers/policy.json" = {
      text = ''
        {
          "default": [{
            "type": "insecureAcceptAnything"
          }]
        }
      '';
    };
  };
}
