{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation {
  name = "claude-sessions";
  src = pkgs.fetchFromGitHub {
    owner = "iannuttall";
    repo = "claude-sessions";
    rev = "c50709bd913fca381290027537701178ac98c1fc";
    hash = "sha256-OCZF60Q0IVTd47voRasiiDk4J905QhtqyDgp96ijR7s=";
  };
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/claude-sessions
    
    # Copy the source files
    cp -r * $out/share/claude-sessions/
    
    # Copy and install the init script
    cp ${./claude-session-init.sh} $out/bin/claude-session-init
    chmod +x $out/bin/claude-session-init
    
    # Update the script to reference the correct commands location
    substituteInPlace $out/bin/claude-session-init \
      --replace 'COMMANDS_SOURCE="''${SCRIPT_DIR}/commands"' \
                'COMMANDS_SOURCE="'$out'/share/claude-sessions/commands"'
  '';
}
