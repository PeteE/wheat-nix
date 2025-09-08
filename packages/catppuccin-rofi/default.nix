{
    lib,
    inputs,
    namespace,
    pkgs,
    stdenvNoCC,
    ...
}:
stdenvNoCC.mkDerivation {
  name = "catppuccin-rofi";
  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "rofi";
    rev = "71fb15577ccb091df2f4fc1f65710edbc61b5a53";
    hash =  "sha256-nWQ1HGZzVsjAVG9NB7EMVWc3lnYggCcTrHjirOBvsiI=";
  };
  installPhase = ''
    mkdir -p $out/themes
    cp -r themes/ $out/
    cp catppuccin-default.rasi $out/
  '';
}
