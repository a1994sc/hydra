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
  pname = "go-containerregistry";
  version = "0.19.1";
  sha256 = "sha256-mHuxwIyPNUWuP4QmMyLMdRlpwSueyKkk9VezJ4Sv2Nw=";
  vendorHash = null;
  # keep-sorted end
  rev = "v" + version;
  bins = [
    "crane"
    "gcrane"
  ];
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "google";
    repo = pname;
  };

  subPackages = [
    "cmd/crane"
    "cmd/gcrane"
  ];

  outputs = [ "out" ] ++ bins;

  nativeBuildInputs = [ installShellFiles ];

  ldflags =
    let
      t = "github.com/google/go-containerregistry";
    in
    [
      "-s"
      "-w"
      "-X ${t}/cmd/crane/cmd.Version=v${version}"
      "-X ${t}/pkg/v1/remote/transport.Version=${version}"
    ];

  postInstall = lib.concatStringsSep "\n" (
    map (bin: ''
      mkdir -p ''$${bin}/bin &&
      mv $out/bin/${bin} ''$${bin}/bin/ &&
      ln -s ''$${bin}/bin/${bin} $out/bin/

      for shell in bash fish zsh; do
        $out/bin/${bin} completion $shell > ${bin}.$shell
        installShellCompletion ${bin}.$shell
      done
    '') bins
  );

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "Tools for interacting with remote images and registries including crane and gcrane";
    homepage = "https://github.com/google/go-containerregistry";
    license = licenses.asl20;
    mainProgram = "crane";
    # keep-sorted end
  };
}
