{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenv
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "markview.nvim";
  version = "v25.1.1";
  src = pkgs.fetchFromGitHub {
    owner = "OXY2DEV";
    repo = "markview.nvim";
    rev = "68902d7cba78a7fe331c13d531376b4be494a05c";
    sha256 = "sha256-JOxjE4EBQ3dcu0eLa8MchFlsSdHadL++eOkpCpDtOHc=";
    fetchSubmodules = true;
  };
  meta.homepage = "https://github.com/OXY2DEV/markview.nvim/";
}
