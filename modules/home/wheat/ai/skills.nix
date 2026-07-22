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
      owner = mkOption {
        type = types.str;
        description = "GitHub repository owner";
      };
      repo = mkOption {
        type = types.str;
        description = "GitHub repository name";
      };
      rev = mkOption {
        type = types.str;
        description = "Git revision (commit sha) to pin the skill(s) to";
      };
      hash = mkOption {
        type = types.str;
        description = "SRI hash of the fetched source tree (nix-prefetch-url --unpack <archive-url>, then nix hash convert)";
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
      src = pkgs.fetchFromGitHub {
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
