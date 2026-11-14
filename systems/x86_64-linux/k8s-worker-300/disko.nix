# vim: ts=2:sw=2:et
# Whole-disk layout for the ThinkCentre Tiny's SATA SSD: ESP + ext4 root.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-Micron_1100_SATA_256GB_1651152D9B13";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
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
}
