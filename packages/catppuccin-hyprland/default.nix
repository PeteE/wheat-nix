{
    lib,
    inputs,
    namespace,
    pkgs,
    stdenvNoCC,
    ...
}:
stdenvNoCC.mkDerivation {
  name = "catppuccin-hyprland";
  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "hyprland";
    rev = "c388ac55563ddeea0afe9df79d4bfff0096b146b";
    hash =  "sha256-p9qxjoD9G1Sx27iLK4lqpY3+S2RClS8FDByo84U8MEc=";
    sparseCheckout = [
      "themes"
    ];
  };
  installPhase = ''
    mkdir -p $out/themes
    cp -r themes/ $out/
  '';
}
