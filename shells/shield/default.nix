{
    lib,
    inputs,
    namespace,
    pkgs,
    ...
}:
pkgs.mkShell {
  # Create your shell
  packages = with pkgs; [
    azure-storage-azcopy
    azure-cli
    just
  ];
}
