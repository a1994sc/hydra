{
  # keep-sorted start
  buildGoModule,
  clusterctl,
  fetchFromGitHub,
  installShellFiles,
  lib,
  testers,
# keep-sorted end
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "clusterctl";
  version = "1.7.0";
  sha256 = "sha256-pG0jr+LCKMwJGDndEZw6vho3zylsoGBVdXqruSS7SDQ=";
  vendorHash = "sha256-ALRnccGjPGuAITtuz79Cao95NhvSczAzspSMXytlw+A=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubernetes-sigs";
    repo = "cluster-api";
  };

  subPackages = [ "cmd/clusterctl" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags =
    let
      t = "sigs.k8s.io/cluster-api/version";
    in
    [
      "-X ${t}.gitMajor=${lib.versions.major version}"
      "-X ${t}.gitMinor=${lib.versions.minor version}"
      "-X ${t}.gitVersion=v${version}"
    ];

  postInstall = ''
    # errors attempting to write config to read-only $HOME
    export HOME=$TMPDIR

    installShellCompletion --cmd clusterctl \
      --bash <($out/bin/clusterctl completion bash) \
      --zsh <($out/bin/clusterctl completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = clusterctl;
    command = "HOME=$TMPDIR clusterctl version";
    version = "v${version}";
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/kubernetes-sigs/cluster-api/releases/tag/${src.rev}";
    description = "Kubernetes cluster API tool";
    homepage = "https://cluster-api.sigs.k8s.io/";
    license = lib.licenses.asl20;
    mainProgram = "clusterctl";
    # keep-sorted end
  };
}
