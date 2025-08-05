{
  pkgs,
  lib,
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "vim-kubernetes";
  version = "";
  src = pkgs.fetchFromGitHub {
    owner = "andrewstuart";
    repo = "vim-kubernetes";
    rev = "d5fe1c319b994149b25c9bee1327dc8b3bebe4b7";
    sha256 = "sha256-BtuGFF78+OtsJr/PdWOJK9vR+QkqCd4MTwq3DZAfmDo=";
  };
}
