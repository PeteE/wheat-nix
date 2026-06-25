# vim: ts=2:sw=2:et
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule {
  pname = "gwctl";
  version = "0.2.0-86-g3380398";

  src = pkgs.fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "gwctl";
    rev = "33803980d7fcb8ac4ef8cad4fa2feaa0f20304a8";
    hash = "sha256-RoqqMhn3nIiiKublacUa1+c5Um4qeoWiZ64UJCqNXRM=";
  };

  vendorHash = "sha256-aQnGU6dfu0ZJeEKmW/JZ4jvYtkM5ouHjHH0fiIzAYrc=";

  ldflags = [
    "-X sigs.k8s.io/gwctl/pkg/version.gitCommit=33803980d7fcb8ac4ef8cad4fa2feaa0f20304a8"
    "-X sigs.k8s.io/gwctl/pkg/version.buildDate=unknown"
  ];

  meta = with lib; {
    description = "Gateway API CLI tool for Kubernetes";
    homepage = "https://github.com/kubernetes-sigs/gwctl";
    license = licenses.asl20;
    mainProgram = "gwctl";
  };
}
