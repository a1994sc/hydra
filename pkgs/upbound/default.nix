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
  pname = "upbound";
  version = "0.30.0";
  sha256 = "sha256-KAWyHlqgj4xz3abSSa1cezpeDTmJbGSZAMffq3p/CyI=";
  vendorHash = "sha256-4o1WJHGHiO9r8RC8hr4KWZBiC8h52la1gKdYaYxEjbk=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "upbound";
    repo = "up";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/upbound/up/internal/version.version=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --bash --name up <(echo complete -C up up)
  '';

  subPackages = [
    "cmd/docker-credential-up"
    "cmd/up"
  ];

  meta = with lib; {
    # keep-sorted start
    description = "CLI for interacting with Upbound Cloud, Upbound Enterprise, and Universal Crossplane (UXP)";
    homepage = "https://upbound.io";
    license = licenses.asl20;
    mainProgram = "up";
    # keep-sorted end
  };
}
