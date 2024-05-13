{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version, prefix_order=pname,version, prefix_order=pname,version, prefix_order=pname,version, prefix_order=pname,version, prefix_order=pname,version,
  pname = "helm";
  version = "3.14.4";
  sha256 = "sha256-pLfDef79hVZCd8jTBKw6WLtd2pXkUuQ4soUIHG++3YM=";
  vendorHash = "sha256-b25LUyr4B4fF/WF4Q+zzrDo78kuSTEPBklKkA4o+DBo=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "helm";
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  ldflags = [
    "-w"
    "-s"
    "-X helm.sh/helm/v3/internal/version.version=v${version}"
    "-X helm.sh/helm/v3/internal/version.gitTreeState=clean"
  ];

  preBuild = ''
    # set k8s version to client-go version, to match upstream
    K8S_MODULES_VER="$(go list -f '{{.Version}}' -m k8s.io/client-go)"
    K8S_MODULES_MAJOR_VER="$(($(cut -d. -f1 <<<"$K8S_MODULES_VER") + 1))"
    K8S_MODULES_MINOR_VER="$(cut -d. -f2 <<<"$K8S_MODULES_VER")"

    ldflags+=" -X helm.sh/helm/v3/internal/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X helm.sh/helm/v3/pkg/lint/rules.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags+=" -X helm.sh/helm/v3/pkg/lint/rules.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
    ldflags+=" -X helm.sh/helm/v3/pkg/chartutil.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags+=" -X helm.sh/helm/v3/pkg/chartutil.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
  '';

  doCheck = false;

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/helm completion $shell > helm.$shell
      installShellCompletion helm.$shell
    done
  '';

  meta = with lib; {
    # keep-sorted start
    description = "A package manager for kubernetes";
    homepage = "https://github.com/kubernetes/helm";
    license = licenses.asl20;
    mainProgram = "helm";
    # keep-sorted end
  };
}
