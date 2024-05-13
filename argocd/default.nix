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
  # keep-sorted start prefix_order=pname,version,
  pname = "argocd";
  version = "2.11.0";
  sha256 = "sha256-qcTP2DM3fq/UMDK6pBoDenLWvMdSdYBzoHu2oRy1GjM=";
  vendorHash = "sha256-c0fTUU5zXI0QDo/bAL4v6zjEp0rNvCpQFAGwpgDWDFY=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    argo = "github.com/argoproj/argo-cd/v2/common";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "argoproj";
    repo = "argo-cd";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  proxyVendor = true;

  subPackages = [ "cmd" ];

  preBuild = ''
    ldflags+=" -X ${flag.argo}.buildDate=$(cat COMMIT)"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X ${flag.argo}.version=${version}"
    "-X ${flag.argo}.gitCommit=${src.rev}"
    "-X ${flag.argo}.gitTag=${src.rev}"
    "-X ${flag.argo}.gitTreeState=clean"
    "-X ${flag.argo}.kubectlVersion=v0.24.2"
  ];

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 "$GOPATH/bin/cmd" -T $out/bin/argocd
    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/argocd version --client | grep ${src.rev} > /dev/null
  '';

  postInstall = ''
    installShellCompletion --cmd argocd \
      --bash <($out/bin/argocd completion bash) \
      --zsh <($out/bin/argocd completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Declarative continuous deployment for Kubernetes";
    homepage = "https://argo-cd.readthedocs.io/en/stable/";
    license = licenses.asl20;
    mainProgram = "argocd";
    # keep-sorted end
  };
}
