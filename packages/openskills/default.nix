# vim: ts=2:sw=2:et
{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "openskills";
  version = "1.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "numman-ali";
    repo = "openskills";
    rev = "57d933a4f0d5c8659bd8b285f50fb9554360f0b3";
    hash = "sha256-mbAnOtaPRz1VYq1oAq9XsVvwpM+yHhUvMe+2lDNcFQo=";
  };

  npmDepsHash = "sha256-3ESEmIuCw/zdTW92Y7tJlRs5sKnu2+7O9HkeX9aKfS4=";

  meta = {
    description = "Universal skills loader for AI coding agents - install and load Anthropic SKILL.md format skills in any agent";
    homepage = "https://github.com/numman-ali/openskills";
    license = lib.licenses.asl20;
    mainProgram = "openskills";
  };
}
