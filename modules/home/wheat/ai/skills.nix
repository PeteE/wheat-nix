# vim: ts=2:sw=2:et
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.ai;

  skillModule = types.submodule {
    options = {
      src = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Pre-fetched source tree to use instead of `pkgs.fetchFromGitHub`
          (e.g. a private-repo flake input pinned via flake.lock, fetched
          over SSH outside the build sandbox). When set, owner/repo/rev/hash
          are ignored.
        '';
      };
      owner = mkOption {
        type = types.str;
        default = "";
        description = "GitHub repository owner (ignored when `src` is set)";
      };
      repo = mkOption {
        type = types.str;
        default = "";
        description = "GitHub repository name (ignored when `src` is set)";
      };
      rev = mkOption {
        type = types.str;
        default = "";
        description = "Git revision (commit sha) to pin the skill(s) to (ignored when `src` is set)";
      };
      hash = mkOption {
        type = types.str;
        default = "";
        description = "SRI hash of the fetched source tree (nix-prefetch-url --unpack <archive-url>, then nix hash convert); ignored when `src` is set";
      };
      subpaths = mkOption {
        type = types.listOf types.str;
        default = [ "" ];
        description = ''
          Subdirectories within the repo, each containing one skill's SKILL.md.
          Use [ "" ] (the default) when the whole repo is a single skill.
          Each skill is installed under ~/.claude/skills/<basename of subpath>
          (or <repo> when subpath is "").
        '';
      };
    };
  };

  skillEntries = concatMap (
    skill:
    let
      src =
        if skill.src != null then
          skill.src
        else
          pkgs.fetchFromGitHub {
            inherit (skill)
              owner
              repo
              rev
              hash
              ;
          };
    in
    map (subpath: {
      name = ".claude/skills/${if subpath == "" then skill.repo else baseNameOf subpath}";
      value = {
        source = if subpath == "" then src else "${src}/${subpath}";
      };
    }) skill.subpaths
  ) cfg.skills;
in
{
  options.wheat.ai.skills = mkOption {
    type = types.listOf skillModule;
    default = [ ];
    description = "Claude Code skills to install declaratively into ~/.claude/skills";
  };

  config = mkIf cfg.enable {
    home.file = listToAttrs skillEntries;
  };
}
