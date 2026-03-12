# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  stdenv,
  makeWrapper,
  ...
}:

stdenv.mkDerivation {
  pname = "azure-util-scripts";
  version = "0.1.0";

  src = ./scripts;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Install all scripts (no extension stripping — scripts are named as-is)
    for script in $(find $src -type f -executable); do
      script_name=$(basename "$script")
      install -Dm755 "$script" "$out/bin/$script_name"

      wrapProgram "$out/bin/$script_name" \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.azure-cli
          pkgs.gum
          pkgs.fzf
          pkgs.jq
        ]}
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Azure utility scripts with interactive TUI (gum/fzf)";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
