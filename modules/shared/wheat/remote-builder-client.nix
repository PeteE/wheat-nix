# vim: ts=2:sw=2:et
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.remote-builder-client;
in {
  options.wheat.remote-builder-client = with types; {
    enable = mkEnableOption "Enable";
  };

  config = mkIf cfg.enable {
    nix.settings = {
      builders = mkForce "@/etc/nix/machines";
    };
    nix.buildMachines = [
      {
        hostName = "ripnix";
        sshUser = "petee";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        maxJobs = 24;
      }
    ];
  };
}
