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
  pname = "matchbox";
  version = "0.11.0";
  sha256 = "sha256-u1VY+zEx2YToz+WxVFaUDzY7HM9OeokbR/FmzcR3UJ8=";
  vendorHash = "sha256-8q94bWVP2gYhGp2wZpxBL8MSIM5rB1UHWS7ZrSz5dSI=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    matchbox = "github.com/poseidon/matchbox/matchbox";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "poseidon";
    repo = pname;
  };

  proxyVendor = true;

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      mkdir bin
      go build -o bin/matchbox -ldflags="${args} -X ${flag.matchbox}/version.Version=${rev}" cmd/matchbox/main.go
    '';

  ldflags = [ "-w" ];

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 bin/matchbox -T $out/bin/matchbox
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/matchbox -version | grep ${src.rev} > /dev/null
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Network boot and provision Fedora CoreOS and Flatcar Linux clusters ";
    homepage = "https://github.com/poseidon/matchbox";
    license = licenses.asl20;
    mainProgram = "matchbox";
    # keep-sorted end
  };
}
