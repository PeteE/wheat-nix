{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.wheat.wifi;
  inherit (lib) mkEnableOption mkIf;

  mkPskProfile = ssid: pskPlaceholder: {
    connection = {
      id = ssid;
      type = "wifi";
      autoconnect = true;
    };
    wifi = {
      mode = "infrastructure";
      inherit ssid;
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = pskPlaceholder;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };
in
{
  options.wheat.wifi = {
    enable = mkEnableOption "Enable wifi";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      iw
    ];

    # NetworkManager owns wifi only; systemd-networkd keeps managing
    # the wired uplink and VM bridge declaratively.
    networking.networkmanager = {
      enable = true;
      unmanaged = [
        "enp0s31f6"
        "br0"
        "interface-name:vm-*"
      ];
      ensureProfiles = {
        environmentFiles = [ config.sops.templates."wifi.env".path ];
        profiles = {
          soma20_5g = mkPskProfile "soma20_5g" "$SOMA20_5G_PSK";
          AA_zzz = mkPskProfile "AA_zzz" "$AA_ZZZ_PSK";
          "cabin-2.4Ghz" = mkPskProfile "cabin-2.4Ghz" "$CABIN_PSK";
        };
      };
    };

    sops.secrets."wifi/soma20_5g_psk" = { };
    sops.secrets."wifi/aa_zzz_psk" = { };
    sops.secrets."wifi/cabin_psk" = { };

    sops.templates."wifi.env".content = ''
      SOMA20_5G_PSK=${config.sops.placeholder."wifi/soma20_5g_psk"}
      AA_ZZZ_PSK=${config.sops.placeholder."wifi/aa_zzz_psk"}
      CABIN_PSK=${config.sops.placeholder."wifi/cabin_psk"}
    '';
  };
}
