{
  home,
  pkgs,
  inputs,
  system,
  ...
}:
{
  wheat = {
    ollama.enable = false;
    git.managedConfig = false;
    work.enable = true;
    minikube.enable = true;
    secrets = {
      enable = true;
    };
    misc.enable = true;
    azure.enable = true;
    aws.enable = true;
    dev-tools.enable = true;
    ai.enable = true;
    ai.mcp.enable = true;
    # To add a skill: pick `rev` via `git ls-remote <repo-url> HEAD`, then
    # compute `hash` with:
    #   h=$(nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<rev>.tar.gz)
    #   nix hash convert --hash-algo sha256 --to sri "$h"
    # (nix hash convert takes the hash as an argument, not via stdin)
    # `subpaths` lists the skill directories (each containing a SKILL.md) to
    # install from the repo; add more entries to pull in additional skills.
    ai.skills = [
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
      # {
      #   owner = "anthropics";
      #   repo = "skills";
      #   rev = "fa0fa64bdc967915dc8399e803be67759e1e62b8";
      #   hash = "sha256-QZ+zJkyLd/42rxgtJEZSUOz9R75Tse6UXW7G0nOkFS8=";
      #   subpaths = [ "skills/algorithmic-art" ];
      # }
    ];
    gcloud.enable = true;
    embedded.enable = false;
    yazi.enable = true;
    attic-client.enable = true;
    k8s = {
      enable = true;
      argocd.enable = true;
      argocd.server = "argocd.corp.tooling.opaque-int.com";
      argocd.useAuthTokenSecret = false;
    };
  };
  home.packages = with pkgs; [
    vault
    codex
    azure-storage-azcopy
    inputs.nixpkgs-stable.legacyPackages."${system}".tailscale
    python312Packages.huggingface-hub
    # moonlight-qt
    # gateway API cli
    pkgs.wheat.gwctl
    pkgs.wheat.openskills
  ];
  home.sessionVariables = {
    AZCOPY_AUTO_LOGIN_TYPE = "AZCLI";
  };
  home.stateVersion = "26.05";
}
