{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenv
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "workspaces-nvim";
  version = "v4.11.0";
  src = pkgs.fetchFromGitHub {
    owner = "natecraddock";
    repo = "workspaces.nvim";
    rev = "55a1eb6f5b72e07ee8333898254e113e927180ca";
    sha256 = "sha256-a3f0NUYooMxrZEqLer+Duv6/ktq5MH2qUoFHD8z7fZA=";
  };
}
