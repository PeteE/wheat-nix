{
    lib,
    inputs,

    # The namespace used for your flake, defaulting to "internal" if not set.
    namespace,

    # All other arguments come from NixPkgs. You can use `pkgs` to pull packages or helpers
    # programmatically or you may add the named attributes as arguments here.
    pkgs,
    stdenvNoCC,
    ...
}:
stdenvNoCC.mkDerivation {
  name = "awesome-copycats";
  src = pkgs.fetchFromGitHub {
    owner = "lcpz";
    repo = "awesome-copycats";
    rev = "368e3705dfe1343ab0d6dfc6360757391f438b60";
    hash =  "sha256-7/HMFEg57l0xrmvIZXU32hFCwuAOGX7VXldhLqvgql0=";
    sparseCheckout = [
      "themes"
    ];
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
