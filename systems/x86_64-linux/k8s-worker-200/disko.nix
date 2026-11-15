# vim: ts=2:sw=2:et
# Supermicro X8DTL is legacy-BIOS only: GPT + 1M BIOS boot partition for GRUB.
# Both SSDs hang off the LSI SAS1068E (mptsas).
{
  disko.devices.disk = {
    # PNY CS1311 120GB: OS
    os = {
      type = "disk";
      device = "/dev/disk/by-id/ata-PNY_CS1311_120GB_SSD_PNY36162191600103814";
      content = {
        type = "gpt";
        partitions = {
          bios = {
            size = "1M";
            type = "EF02";
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
    # 223GB SATA SSD: k3s data (containerd images, local-path volumes).
    # Partition name kept from the hypervisor layout so the existing
    # filesystem is reused as-is.
    vms = {
      type = "disk";
      device = "/dev/disk/by-id/ata-SATA_SSD_17110324001257";
      content = {
        type = "gpt";
        partitions = {
          libvirt = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/rancher";
              # Missing disk must not drop boot to emergency mode (no SSH);
              # k3s itself requires this mount, see default.nix
              mountOptions = [
                "defaults"
                "nofail"
                "x-systemd.device-timeout=30s"
              ];
            };
          };
        };
      };
    };
  };
}
