{
    home,
    inputs,
    ...
}:
{
  home.stateVersion = "25.11";
  wheat = {
    distrobox.enable = true;
  };

  # virtualisation.libvirt.swtpm.enable = true;
  # virtualisation.libvirt.connections."qemu:///session".domains =
  #   [
  #     {
  #       active = true;
  #       definition = inputs.nixvirt.lib.domain.writeXML (inputs.nixvirt.lib.domain.templates.linux
  #         {
  #           name = "oas";
  #           uuid = "cc7439ed-36af-4696-a6f2-1f0c4474d87e";
  #           memory = { count = 2; unit = "GiB"; };
  #           virtio_net = true;
  #           virtio_drive = true;
  #           # storage_vol = { pool = "MyPool"; volume = "Penguin.qcow2"; }
  #           backing_vol = /home/petee/VMs/oas.qcow2;
  #         });
  #     }
  #   ];
}
