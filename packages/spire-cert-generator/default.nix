# vim: ts=2:sw=2:et
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "spire-cert-generator";
  version = "1.0.0";

  src = ./spire-cert-generator.sh;
  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/spire-cert-generator
    chmod +x $out/bin/spire-cert-generator

    wrapProgram $out/bin/spire-cert-generator \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.openssl
          pkgs.gnused
          pkgs.coreutils
          pkgs.sops
          pkgs.git
        ]
      }
  '';

  meta = with lib; {
    description = "Generate SPIRE x509pop CA and node certificates";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
