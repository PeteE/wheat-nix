{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation {
  name = "catppuccin-wallpapers";
  source = pkgs.fetchFromGitHub {
    owner = "zhichaoh";
    repo = "catppuccin-wallpapers";
    rev = "1023077979591cdeca76aae94e0359da1707a60e";
    hash = "sha256-h+cFlTXvUVJPRMpk32jYVDDhHu1daWSezFcvhJqDpmU=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
