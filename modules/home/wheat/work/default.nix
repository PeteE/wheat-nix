{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.work;
  
  work_scripts = pkgs.stdenv.mkDerivation {
    pname = "work-scripts";
    src = ./scripts;
    version = "0.1";
    installPhase = ''
      mkdir -p $out/bin
      cp $src/* $out/bin
      chmod +x $out/bin/*
    '';
  };
in {
  options.wheat.work = with types; {
    enable = mkEnableOption "Enable";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      work_scripts
    ];
  };
}
