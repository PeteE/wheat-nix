{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.entertainment;
in {
  options.wheat.entertainment = {
    vlc = {
      enable = mkEnableOption "Enable VLC media player";
    };

    spotify = {
      enable = mkEnableOption "Enable Spotify and related services";
    };
  };

  config = mkMerge [
    (mkIf cfg.vlc.enable {
      home.packages = with pkgs; [
        vlc
      ];
    })

    (mkIf cfg.spotify.enable {
      home.packages = with pkgs; [
        spotify
      ];
    })
  ];
}
