{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenv
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "snacks-nvim";
  version = "v2.20.0";
  doCheck = false;
  src = pkgs.fetchFromGitHub {
    owner = "folke";
    repo = "snacks.nvim";
    rev = "5eac729fa290248acfe10916d92a5ed5e5c0f9ed";
    sha256 = "sha256-iXfOTmeTm8/BbYafoU6ZAstu9+rMDfQtuA2Hwq0jdcE=";
  };
}
