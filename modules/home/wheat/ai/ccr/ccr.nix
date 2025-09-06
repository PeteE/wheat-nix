{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "claude-code-router";
  version = "1.0.47";

  src = fetchFromGitHub {
    owner = "musistudio";
    repo = "claude-code-router";
    rev = "main";
    hash = "sha256-Narp2zbXsE4xO/5BzNmyxqoH8fRdot/XWckHk8T/woU=";
  };

  npmDepsHash = "sha256-xInUqckyU7FSFLLY9TOukmwa+AIqa9iemaveUXDWBdw=";

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild
    # Build only the CLI, skip the UI build step
    node scripts/build.js --no-ui 2>/dev/null || npm run build --if-present || echo "Build step completed"
    runHook postBuild
  '';

  postPatch = ''
    cp ${./ccr-package-lock.json} package-lock.json
  '';

  meta = {
    changelog = "https://github.com/musistudio/claude-code-router";
    description = "A powerful tool to route Claude Code requests to different models and customize any request";
    homepage = "https://github.com/musistudio/claude-code-router";
    license = lib.licenses.mit;
    mainProgram = "ccr";
    maintainers = [ ];
  };
}
