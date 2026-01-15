# vim: ts=2:sw=2:et
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
    modulesPath,
    ...
}:
with lib; let
  cfg = config.wheat.chromium;
in {
  options.wheat.chromium = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,VaapiVideoDecodeLinuxGL"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        "--ozone-platform=wayland"
        "--force-device-scale-factor=1"
      ];
    };
    home.packages = with pkgs; [
      libva-utils
    ];
  };
}
