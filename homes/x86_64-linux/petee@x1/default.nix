{
  inputs,
  pkgs,
  system,
  ...
}:
{

  wheat = {
    minikube.enable = true;
    ollama.enable = false;
    distrobox.enable = true;
    ai = {
      enable = true;
      mcp = {
        enable = true;
      };
      aichat.enable = true;
      caveman.enable = true;
      ollamaHost = "192.168.1.149"; # m4
      claude = {
        settings = {
          env = {
            CLAUDE_CODE_ENABLE_TELEMETRY = "0";
            CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
          };
          permissions = {
            allow = [
              "Bash"
              "Read(*)"
              "WebFetch(domain:github.com)"
              "mcp__claude_ai_Notion__notion-fetch"
            ];
            deny = [ ];
            defaultMode = "auto";
          };
          worktree.baseRef = "fresh";
          enabledPlugins = {
            "gopls-lsp@claude-plugins-official" = true;
            "superpowers@claude-plugins-official" = false;
          };
          effortLevel = "medium";
          awaySummaryEnabled = false;
          tui = "fullscreen";
          theme = "dark";
          editorMode = "vim";
          verbose = false;
          teammateMode = "tmux";
          remoteControlAtStartup = true;
          skipAutoPermissionPrompt = true;
          enableArtifact = false;
        };
        skills = [
          {
            owner = "obra";
            repo = "superpowers";
            rev = "d884ae04edebef577e82ff7c4e143debd0bbec99";
            hash = "sha256-kHdQ9e44doBk2yYW88tMSCqVG8ycYcvJSZlrIziXhpA=";
            subpaths = [
              "skills/brainstorming"
              "skills/requesting-code-review"
              "skills/using-superpowers"
              "skills/dispatching-parallel-agents"
              "skills/subagent-driven-development"
              "skills/verification-before-completion"
              "skills/executing-plans"
              "skills/systematic-debugging"
              "skills/writing-plans"
              "skills/finishing-a-development-branch"
              "skills/test-driven-development"
              "skills/writing-skills"
              "skills/receiving-code-review"
              "skills/using-git-worktrees"
            ];
          }
        ];
      };
    };
    # To add a skill: pick `rev` via `git ls-remote <repo-url> HEAD`, then
    # compute `hash` with:
    #   h=$(nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<rev>.tar.gz)
    #   nix hash convert --hash-algo sha256 --to sri "$h"
    # (nix hash convert takes the hash as an argument, not via stdin)
    # `subpaths` lists the skill directories (each containing a SKILL.md) to
    # install from the repo; add more entries to pull in additional skills.

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
    chromium

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
