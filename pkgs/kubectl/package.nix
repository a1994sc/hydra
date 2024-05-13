{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  makeWrapper,
  rsync,
  runtimeShell,
  which,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version, prefix_order=pname,version, prefix_order=pname,version,
  pname = "kubectl";
  version = "1.29.4";
  sha256 = "sha256-7Rxbcsl77iFiHkU/ovyn74aXs/i5G/m5h5Ii0y1CRho=";
  vendorHash = null;
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubernetes";
    repo = "kubernetes";
  };

  outputs = [
    "out"
    "man"
    "convert"
  ];

  WHAT = lib.concatStringsSep " " [
    "cmd/${pname}"
    "cmd/${pname}-convert"
  ];

  buildPhase = ''
    runHook preBuild
    substituteInPlace "hack/update-generated-docs.sh" --replace "make" "make SHELL=${runtimeShell}"
    patchShebangs ./hack ./cluster/addons/addon-manager
    make "SHELL=${runtimeShell}" "WHAT=$WHAT"
    ./hack/update-generated-docs.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D _output/local/go/bin/kubectl -t $out/bin
    install -D _output/local/go/bin/kubectl-convert -t $convert/bin

    installManPage docs/man/man1/kubectl*

    for shell in bash fish zsh; do
      $out/bin/kubectl completion $shell > kubectl.$shell
      installShellCompletion kubectl.$shell
    done

    runHook postInstall
  '';

  GOWORK = "off";

  nativeBuildInputs = [
    makeWrapper
    which
    rsync
    installShellFiles
  ];

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "Kubernetes CLI";
    homepage = "https://github.com/kubernetes/kubectl";
    license = licenses.asl20;
    mainProgram = "kubectl";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
