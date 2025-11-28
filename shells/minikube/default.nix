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
    minikube
    # helm
    k9s
    kubectl
  ];
}
