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
    # 223GB SATA SSD (ex k8s-worker-200 disk): VM images
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
              mountpoint = "/var/lib/libvirt";
            };
          };
        };
      };
    };
  };
}
