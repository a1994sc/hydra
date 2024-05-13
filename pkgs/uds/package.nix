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
  pname = "uds";
  version = "0.10.4";
  sha256 = "sha256-2qc4uaqh6wNjY8pS/bRDNV7W2mB/lqznwSjQJpVNLuQ=";
  vendorHash = "sha256-SuHmi4oxpcmfGCzhAMt/hcBMms5sKXaGpg9RrW8wV1U=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "defenseunicorns";
    repo = "uds-cli";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X 'github.com/defenseunicorns/uds-cli/src/config.CLIVersion=v${version}'"
    "-X 'github.com/defenseunicorns/zarf/src/config.ActionsCommandZarfPrefix=zarf'"
  ];

  subPackages = [ "." ];

  doCheck = false;

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o uds -ldflags="${args}" main.go
    '';

  installPhase = ''
    install -Dm755 uds -t $out/bin
    runHook postInstall
  '';

  postInstall = ''
    export K9S_LOGS_DIR=$(mktemp -d)
    for shell in bash fish zsh; do
      $out/bin/uds completion --no-log-file $shell > uds.$shell
      installShellCompletion uds.$shell
    done
  '';

  meta = with lib; {
    # keep-sorted start
    description = "DevSecOps for Air Gap & Limited-Connection Systems";
    homepage = "https://github.com/defenseunicorns/uds-cli.git";
    license = licenses.asl20;
    mainProgram = "uds";
    # keep-sorted end
  };
}
