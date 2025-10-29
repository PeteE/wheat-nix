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
    libvirtd.enable = mkEnableOption "Enable";
    libvirtUri = mkOption {
      type = str;
      default = "qemu+ssh://petee@192.168.1.51/system";
      description = "Default libvirt URI for virsh connections";
    };
    group = mkOption {
      type = str;
      default = "libvirtd";
      description = "Group to add the user to for libvirt access";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = mkIf cfg.libvirtd.enable {
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

    environment.systemPackages = with pkgs; [
      virt-manager
    ];

    environment.variables = {
      LIBVIRT_DEFAULT_URI = cfg.libvirtUri;
    };
  };
}
