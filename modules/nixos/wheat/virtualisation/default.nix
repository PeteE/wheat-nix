{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.virtualisation;
in {
  options.wheat.virtualisation = with types; {
    enable = mkEnableOption "Enable";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        # runAsRoot = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd];
          };
        };
      };
    };

    wheat.user.extraGroups = [ "libvirtd" ];
    environment.systemPackages = with pkgs; [
      virt-manager
    ];

  };
}
