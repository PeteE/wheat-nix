{
    lib,
    inputs,
    namespace,
    pkgs,
    stdenvNoCC,
    ...
}:
stdenvNoCC.mkDerivation {
  name = "btop-catppuccin-theme";
  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "btop";
    rev = "f437574b600f1c6d932627050b15ff5153b58fa3";
    hash =  "sha256-h9ZD8S0Qsj02BLaCvBIQ3RnH7o8ozVNHlW4GlRFM8gM=";
    sparseCheckout = [
      "themes"
    ];
  };
  installPhase = ''
    mkdir -p $out/themes
    cp -r themes/ $out/
  '';
}
