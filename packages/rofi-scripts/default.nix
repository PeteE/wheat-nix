# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  stdenv,
  makeWrapper,
  ...
}:

stdenv.mkDerivation {
  pname = "rofi-scripts";
  version = "0.1.0";

  src = ./scripts;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Install all shell scripts
    for script in $(find $src -name "*.sh" -type f); do
      script_name=$(basename "$script" .sh)
      install -Dm755 "$script" "$out/bin/$script_name"
      
      # Wrap scripts to ensure dependencies are in PATH
      wrapProgram "$out/bin/$script_name" \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.rofi
            pkgs.clipcat
          ]
        }
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Custom rofi scripts for clipboard management";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
