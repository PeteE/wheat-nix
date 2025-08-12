{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.libvirt-vms;
  inherit (lib) mkEnableOption mkOption mkIf;
in {
  options.wheat.libvirt-vms = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    virtualisation.libvirt = {
      enable = true;
      verbose = true;
      swtpm.enable = true;
      connections."qemu:///system" = {
        domains = [
          # {
          #   definition = nixvirt.lib.domain.writeXML (nixvirt.lib.domain.templates.windows
          #     {
          #       name = "shield";
          #       uuid = "d08631d0-6209-42c2-9d4b-739b7b52d815";
          #       memory = { count = 4; unit = "GiB"; };
          #       storage_vol = { pool = "MyPool"; volume = "shield.qcow2"; };
          #       backing_vol = /home/petee/VM-Storage/Base.qcow2;
          #       install_vol = /home/petee/VM-Storage/Win11_23H2_EnglishInternational_x64v2.iso;
          #       bridge_name = "virbr0";
          #       nvram_path = /home/ashley/VM-Storage/shield.nvram;
          #       virtio_net = true;
          #       virtio_drive = true;
          #       install_virtio = true;
          #     }
          #   );
          # }
        ];
        pools = [
        ];
      };
    };
  };
}
