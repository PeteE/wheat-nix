{
  pkgs,
  lib,
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "nvim-base64";
  version = "v0.2.2";
  src = pkgs.fetchFromGitHub {
    owner = "deponian";
    repo = "nvim-base64";
    rev = "0.2.0";
    sha256 = "sha256-zBhSQCxcFh5s1ekyoLy48IKB+nkj9JsUfz+KWSYGVYQ=";
  };
}
