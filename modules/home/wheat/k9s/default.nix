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
  cfg = config.wheat.k9s;
in {
  # This module will contain any work-related stuff
  options.wheat.k9s = with types; {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.zsh.envExtra = ''
      export K9S_EDITOR=nvim
    '';

    programs.k9s = {
      enable = true;
      aliases = {
        # TOOD - add aliases:
        # es = "externalsecret";
        # pp = "v1/pods";
      };
      skins = {
        catppuccin = ./skins/catppuccin-mocha.yaml;
      };
      settings = {
        # Enable periodic refresh of resource browser windows. Default false
        liveViewAutoRefresh = false;
        # Represents ui poll intervals in seconds. Default 2secs
        refreshRate = 2;
        # Overrides the default k8s api server requests timeout. Defaults 120s
        apiServerTimeout = "10s";
        # Number of retries once the connection to the api-server is lost. Default 15.
        maxConnRetry = 5;
        # Specifies if modification commands like delete/kill/edit are disabled. Default is false
        readOnly = false;
        # This setting allows users to specify the default view, but it is not set by default.
        defaultView =  "";
        # Toggles whether k9s should exit when CTRL-C is pressed. When set to true, you will need to exist k9s via the :quit command. Default is false.
        noExitOnCtrlC = false;
        # Default port forward host
        portForwardAddress = "localhost";
        skipLatestRevCheck = true;

      };

    };
  };
}
