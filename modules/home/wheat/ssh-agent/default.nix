{
    lib,
    pkgs,
    inputs,
    namespace,
    target,
    format,
    virtual,
    host,
    config,
    ...
}:
with lib; let
  cfg = config.wheat.services.ssh-agent;
in {
  options = {
    wheat.services.ssh-agent = with types; {
      enable = mkEnableOption "Enable";
    };
  };

  config = mkIf cfg.enable {
    services.ssh-agent.enable = true;
  };
}

