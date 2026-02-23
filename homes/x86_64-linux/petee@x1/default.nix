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

      ollamaHost = "192.168.1.115"; # m4
      mcp.enable = true;
      aichat.enable = true;
      opencommit.enable = true;
      # ccr = {
      #   enable = true;
      #   providers = [
      #     {
      #       name = "openai";
      #       api_base_url = "https://api.openai.com/v1/chat/completions";
      #       api_key = "$OPENAI_API_KEY";
      #       models = ["gpt-5-nano" "gpt-5"];
      #     }
      #     {
      #       name = "openrouter";
      #       api_base_url = "https://openrouter.ai/api/v1/chat/completions";
      #       api_key = "$OPENROUTER_API_KEY";
      #       models = ["openrouter/free"];
      #     }
      #     {
      #       name = "m4";
      #       api_base_url = "http://m4:8080/v1/chat/completions";
      #       api_key = "dummy";
      #       models = ["mistral"];
      #     }
      #   ];
      #   router = {
      #     # default = "openai,gpt-5";
      #     default = "openrouter,openrouter/free";
      #     background = "m4,mistral";
      #     longContextThreshold = 60000;
      #     webSearch = "openai,gpt-5";
      #   };
      # };
    };

    misc.enable = true;
    zoom.enable = true;
    work.enable = true;
    rofi.enable = true;
    clipcat.enable = true;
    firefox.enable = true;
    hyprland.enable = false;
    devenv.enable = true;
    zed-editor.enable = true;
    # vscode.enable = true;
    aws.enable = true;
    azure.enable = true;
    dev-tools.enable = true;
    gcloud.enable = true;
    embedded.enable = true;
    attic-client.enable = true;
    signal.enable = true;
    kanidm.enable = true;  # CLI client for idp.wheat-dn42.net
  };

  home.packages = with pkgs; [
    miro
    spotify
    pandoc
    tectonic
  ];

  programs.zsh.initContent = ''
    s-wheat() { ssh rpi4 -- sudo spire-server "$@" -socketPath /run/spire/server/private/api.sock; }
    s-wheat-k8s() { kubectl --context wheat exec -n spire -it spire-server-0 -- spire-server "$@"; }
  '';

  # notificaiton system
  services.mako = {
    enable = true;
    defaultTimeout = 5000;  # 5 seconds in milliseconds
    extraConfig = ''
      [app-name=Slack]
      default-timeout=3000
    '';
  };

  programs.noctalia-shell = {
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

  home.stateVersion = "25.11";
}
