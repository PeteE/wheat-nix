{
  pkgs,
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "kulala-nvim";
  version = "v4.11.0";
  src = pkgs.fetchFromGitHub {
    owner = "mistweaverco";
    repo = "kulala.nvim";
    rev = "a785d0dcbeee14b4bac0da42be04e1d3f0e73f64";
    sha256 = "sha256-V96WFRQ8M9hiT58SM+eKt8RZhbXtoFARSpekBIOoG3s=";
  };
}
