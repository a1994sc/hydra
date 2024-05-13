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
  pname = "packer";
  version = "1.10.2";
  sha256 = "sha256-/ViyS7srbOoZJDvDCRoNYWkdCYi3F1Pr0gSSFF0M1ak=";
  vendorHash = "sha256-JNOlMf+PIONokw5t2xhz1Y+b5VwRDG7BKODl8fHCcJY=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "hashicorp";
    repo = pname;
  };

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --bash --name packer <(echo complete -C $out/bin/packer packer)
    installShellCompletion --zsh contrib/zsh-completion/_packer
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/hashicorp/packer/blob/v${version}/CHANGELOG.md";
    description = "A tool for creating identical machine images for multiple platforms from a single source configuration";
    homepage = "https://www.packer.io";
    license = licenses.bsl11;
    # keep-sorted end
  };
}
