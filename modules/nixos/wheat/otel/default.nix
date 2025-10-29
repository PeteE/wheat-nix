# vim: ts=2:sw=2:et
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wheat.services.otel;
in {
  options.wheat.services.otel = {
    enable = mkEnableOption "otel";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go_1_23 # TODO(pete): refactor ocb
      opentelemetry-collector-builder
      gcc
    ];
    services.opentelemetry-collector = {
      enable = true;
      settings = {
        exporters = {
          debug = {
            verbosity = "basic";
          };
        };
        processors = { };
        receivers = {
          # journald = {
          #   directory = "/var/log/journald";  # TODO option
          #   units = [
          #     "sshd"
          #   ];
          # };
          otlp = {
            protocols = {
              grpc = {
                endpoint = "127.0.0.1:4317";
              };
              http = {
                endpoint = "127.0.0.1:4318";
              };
            };
          };
        };
        service = {
          pipelines = {
            metrics = {
              receivers = [ "otlp" ];
              processors = [ ];
              exporters = [ "debug" ];
            };
            logs = {
              receivers = [
                "otlp"
                # "journald"
              ];
              processors = [ ];
              exporters = [ "debug" ];
            };
          };
        };
      };
    };
  };
}
