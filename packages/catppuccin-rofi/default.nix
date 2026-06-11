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
    hash = "sha256-81eeFjwM/haPjIEWkZPp1JSDwhWbWDAuKtWiCg7P9Q0=";
  };
  installPhase = ''
    mkdir -p $out/themes
    cp -r themes/ $out/
    cp catppuccin-default.rasi $out/
  '';
}
