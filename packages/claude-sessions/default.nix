{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation {
  name = "";
  source = pkgs.fetchFromGitHub {
    owner = "iannuttall";
    repo = "claude-sessions";
    rev = "c50709bd913fca381290027537701178ac98c1fc";
    hash = "";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
