{
    lib,
    inputs,
    namespace,
    pkgs,
    stdenv,
    ...
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-super-fingers";
  version = "unstable-2024-02-08";
  src = pkgs.fetchFromGitHub {
    owner = "artemave";
    repo = "tmux_super_fingers";
    rev = "518044ef78efa1cf3c64f2e693fef569ae570ddd";
    sha256 = "sha256-iKfx9Ytk2vSuINvQTB6Kww8Vv7i51cFEnEBHLje+IJw=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
