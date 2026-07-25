# vim: ts=2:sw=2:et
#
# Declarative install of https://github.com/JuliusBrussee/caveman — no
# imperative `npx caveman` installer, no mutable state outside the nix store.
# Skills/agents/hooks are symlinked into ~/.claude/{skills,agents,hooks} the
# same way wheat.ai.skills does; the hook wiring + statusline are contributed
# into wheat.ai.claude.settings (see ai/default.nix), which only lands on disk
# when wheat.ai.claude.manage = true.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.ai.caveman;

  src = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "v${cfg.version}";
    inherit (cfg) hash;
  };

  hooksDir = "${config.home.homeDirectory}/.claude/hooks";
  node = lib.getExe pkgs.nodejs;

  skillNames = [
    "caveman"
    "caveman-commit"
    "caveman-review"
    "caveman-help"
    "caveman-compress"
    "caveman-stats"
    "cavecrew"
  ];

  agentFiles = [
    "cavecrew-builder.md"
    "cavecrew-investigator.md"
    "cavecrew-reviewer.md"
  ];
in
{
  options.wheat.ai.caveman = {
    enable = mkEnableOption "caveman (compressed caveman-style prose for Claude Code)";

    version = mkOption {
      type = types.str;
      default = "1.9.1";
      description = "caveman release tag to pin (without the leading v)";
    };

    hash = mkOption {
      type = types.str;
      default = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
      description = "SRI hash of the fetched source tree for `version`";
    };
  };

  config = mkIf cfg.enable {
    home.file =
      (listToAttrs (
        map (name: {
          name = ".claude/skills/${name}";
          value = {
            source = "${src}/skills/${name}";
          };
        }) skillNames
      ))
      // (listToAttrs (
        map (name: {
          name = ".claude/agents/${name}";
          value = {
            source = "${src}/agents/${name}";
          };
        }) agentFiles
      ))
      // {
        ".claude/hooks".source = "${src}/src/hooks";
      };

    # caveman.enable implies "manage ~/.claude/settings.json declaratively" —
    # the hooks below are useless without being wired in, and there's no
    # non-destructive way to merge into a hand-edited file from here.
    wheat.ai.claude.manage = mkDefault true;

    wheat.ai.claude.settings = {
      hooks = {
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = ''"${node}" "${hooksDir}/caveman-activate.js"'';
                timeout = 5;
                statusMessage = "Loading caveman mode...";
              }
            ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = ''"${node}" "${hooksDir}/caveman-mode-tracker.js"'';
                timeout = 5;
                statusMessage = "Tracking caveman mode...";
              }
            ];
          }
        ];
      };
      statusLine = {
        type = "command";
        command = ''bash "${hooksDir}/caveman-statusline.sh"'';
      };
    };
  };
}
