{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "catppuccin-mako";
  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "mako";
    rev = "92844f144e72f2dc8727879ec141ffdacf3ff6a1";
    hash = "sha256-jgiZ+CrM4DX2nZR5BjjD9/Rk5CGGUy3gq9CCvYzp5Vs=";
  };
  installPhase = ''
    mkdir -p $out/themes
    cp -r themes/ $out/
  '';
}
