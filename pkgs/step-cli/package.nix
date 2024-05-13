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
  pname = "step-cli";
  version = "0.25.2";
  sha256 = "sha256-ZPfsOS/UjH32Hd48hYm0fXPyXpVCE/nzjoUi1DZhhIg=";
  vendorHash = "sha256-R9UJHXs35/yvwlqu1iR3lJN/w8DWMqw48Kc+7JKfD7I=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "smallstep";
    repo = "cli";
  };

  ldflags = [
    "-w"
    "-s"
    "-X main.Version=${version}"
  ];

  preCheck = ''
    # Tries to connect to smallstep.com
    rm command/certificate/remote_test.go
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/step completion $shell > step.$shell
      installShellCompletion step.$shell
    done
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/smallstep/cli/blob/v${version}/CHANGELOG.md";
    description = "A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc";
    homepage = "https://smallstep.com/cli/";
    license = lib.licenses.asl20;
    mainProgram = "step";
    # keep-sorted end
  };
}
