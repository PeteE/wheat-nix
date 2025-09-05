{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "slack-mcp-server";
  version = "1.1.24";

  src = fetchFromGitHub {
    owner = "korotovsky";
    repo = "slack-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sZHnrex66eAJT5kvQ3X/1hc7pyS4n/UcZIjO2KNoCUQ=";
  };

  vendorHash = "sha256-gSe0UxL/qeGpFjvJHh3CKg8t2apRRKijYGYoaY6+T9A=";

  subPackages = [ "cmd/slack-mcp-server" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  __darwinAllowLocalNetworking = true;

  doInstallCheck = false;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/korotovsky/slack-mcp-server/releases/tag/v${finalAttrs.version}";
    description = "Slack MCP (Model Context Protocol) server";
    homepage = "https://github.com/korotovsky/slack-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "slack-mcp-server";
    maintainers = with lib.maintainers; [ ];
  };
})
