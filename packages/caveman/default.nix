# vim: ts=2:sw=2:et
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "caveman";
  version = "1.9.1";

  src = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "v${version}";
    hash = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/caveman
    cp -r bin src agents skills plugins commands dist README.md LICENSE $out/lib/caveman/

    makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/caveman \
      --add-flags "$out/lib/caveman/bin/install.js"

    runHook postInstall
  '';

  meta = {
    description = "Makes AI coding agents respond in compressed caveman-style prose, cutting output tokens with full technical accuracy";
    homepage = "https://github.com/JuliusBrussee/caveman";
    license = lib.licenses.mit;
    mainProgram = "caveman";
    platforms = lib.platforms.unix;
  };
}
