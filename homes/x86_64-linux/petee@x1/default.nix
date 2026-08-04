{
  inputs,
  pkgs,
  system,
  ...
}:
{

  wheat = {
    ollama.enable = false;
    distrobox.enable = true;
    ai = {
      enable = true;

      ollamaHost = "192.168.1.149"; # m4
      mcp.enable = true;
      aichat.enable = true;
      opencommit.enable = true;
      caveman.enable = true;
    };

    misc.enable = true;
    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    firefox.enable = true;
    devenv.enable = true;
    # zed-editor.enable = true;
    # vscode.enable = true;
    aws.enable = true;
    azure.enable = true;
    dev-tools.enable = true;
    gcloud.enable = true;
    embedded.enable = true;
    attic-client.enable = true;
    signal.enable = true;
    kanidm.enable = true; # CLI client for idp.wheat-dn42.net
    screenshot.enable = true;
    niri.enable = true;
  };

  home.packages = with pkgs; [
    miro
    spotify
    pandoc
    tectonic

    # neato tui for network
    inputs.matthart1983-netwatch.packages."${pkgs.stdenv.hostPlatform.system}".netwatch
  ];

  programs.zsh.initContent = ''
    s-wheat() { ssh rpi4 -- sudo spire-server "$@" -socketPath /run/spire/server/private/api.sock; }
    s-wheat-k8s() { kubectl --context wheat exec -n spire -it spire-server-0 -- spire-server "$@"; }
  '';

  # notificaiton system
  services.mako = {
    enable = true;
    settings.default-timeout = 5000; # 5 seconds in milliseconds
    extraConfig = ''
      [app-name=Slack]
      default-timeout=3000
    '';
  };

  programs.noctalia = {
    enable = true;
    # settings = {
    #   # configure noctalia here
    #   bar = {
    #     density = "compact";
    #     position = "right";
    #     showCapsule = false;
    #     widgets = {
    #       left = [
    #         {
    #           id = "ControlCenter";
    #           useDistroLogo = true;
    #         }
    #         {
    #           id = "WiFi";
    #         }
    #         {
    #           id = "Bluetooth";
    #         }
    #       ];
    #       center = [
    #         {
    #           hideUnoccupied = false;
    #           id = "Workspace";
    #           labelMode = "none";
    #         }
    #       ];
    #       right = [
    #         {
    #           alwaysShowPercentage = false;
    #           id = "Battery";
    #           warningThreshold = 30;
    #         }
    #         {
    #           formatHorizontal = "HH:mm";
    #           formatVertical = "HH mm";
    #           id = "Clock";
    #           useMonospacedFont = true;
    #           usePrimaryColor = true;
    #         }
    #       ];
    #     };
    #   };
    #   colorSchemes.predefinedScheme = "Monochrome";
    #   general = {
    #     # avatarImage = "/home/drfoobar/.face";
    #     radiusRatio = 0.2;
    #   };
    #   location = {
    #     monthBeforeDay = true;
    #     name = "Minneapolis, Minnesota";
    #   };
    # };
    # this may also be a string or a path to a JSON file,
    # but in this case must include *all* settings.
  };

  home.stateVersion = "26.05";
}
