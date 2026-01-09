# Just goofing around with containerd+minikube+coco+cloud-hypervisor
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.coco;
in {
  options.wheat.coco  = with types; {
    enable = mkEnableOption "Enable";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containerd = {
        enable = true;
      };
      podman.enable = true; 
    };
    environment.systemPackages = with pkgs; [
      minikube
      cloud-hypervisor
    ];

    # environment.variables = {
    #   LIBVIRT_DEFAULT_URI = cfg.libvirtUri;
    # };
  };
}
