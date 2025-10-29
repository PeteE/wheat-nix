# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.services.suricata;
in {
  options.wheat.services.suricata = {
    enable = mkEnableOption "Security settings";
    HOME_NET = mkOption {
      type = types.str;
      default = "[192.168.1.0/24]";
      description = "CIDR Range of the monitored interface and all the local networks in use";
    };
    EXTERNAL_NET = mkOption {
      type = types.str;
      default = "!$HOME_NET";
      description = "CIDR Range for all other networks";
    };
    interface = mkOption {
      type = types.str;
      example = "br0";
      description = "Network interface to run suricata on";
    };
    includes = mkOption {
      type = types.listOf types.str;
      description = "additional file to load -- nice for debugging without re-runing nix";
      default = [ ];
    };
  };
  config = mkIf cfg.enable {
    services.suricata = {
      enable = true;
      settings = {
        includes = cfg.includes;
        vars.address-groups.HOME_NET = cfg.HOME_NET;
        vars.address-groups.EXTERNAL_NET = cfg.EXTERNAL_NET;
        outputs = [
          {
            eve-log = {
              enabled = true;
              type = "redis";
              filetype = "redis";
              redis = {
                server = "127.0.0.1";
                port = 6379;
                async = true;
                mode = "list";     ## possible values: list|lpush (default), rpush, channel|publish
                                   ## lpush and rpush are using a Redis list. "list" is an alias for lpush
                                   ## publish is using a Redis channel. "channel" is an alias for publish
                key = "suricata";  ## key or channel to use (default to suricata)
                pipelining = {
                  enabled = true;
                  batch-size = 10;
                };
              };
              types = [
                {
                  alert.tagged-packets = true;
                  metadata = {
                    app-layer = true;
                    flow = true;
                    rule.metadata = true;
                  };
                }
                {
                  http.extended = true;
                }
                {
                  anomaly.enabled = true;
                }
                {
                  dns.enabled = true;
                }
                {
                  tls = {
                    extended = true;
                    ja4 = "on";
                  };
                }
                {
                  quic.ja4 = "on";
                }
                {
                  ssh.enabled = true;
                }
              ];
            };
          }
          # {
          #   tls-log = {
          #     enabled = true;
          #     filename = "tls.log";
          #     extended = true;
          #     append = true;
          #   };
          # }
          # {
          #   tls-store = {
          #     enabled = true;
          #     certs-log-dir = "certs";
          #   };
          # }
          # {
          #   stats = {
          #     enabled = false;
          #     filename = "stats.log";
          #     totals = true;
          #   };
          # }
        ];
        af-packet = [
          {
            interface = cfg.interface;
            cluster-id = "99";
            cluster-type = "cluster_flow";
            defrag = "yes";
            tpacket-v3 = "yes";
          }
        ];
        app-layer.protocols = {
          telnet.enabled = "yes";
          dnp3.enabled = "no";
          modbus.enabled = "no";
        };
      };
    };
  };
}
