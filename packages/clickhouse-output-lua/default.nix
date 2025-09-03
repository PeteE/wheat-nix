{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenv
}:
stdenv.mkDerivation {
  name = "suricata-clickhouse-output";
  source = ./src;
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
