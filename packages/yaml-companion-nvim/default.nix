{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenv
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "yaml-companion-nvim";
  version = "0.1.3";
  doCheck = false;
  src = pkgs.fetchFromGitHub {
    owner = "someone-stole-my-name";
    repo = "yaml-companion.nvim";
    rev = "03f66e5e9c8b26a35b14593f24697f9a3bc64e48";
    sha256 = "sha256-9c+9oxrCNFMlAsRaamsimYbrYYXHpR4APljYMsjlrzY=";
  };
}
