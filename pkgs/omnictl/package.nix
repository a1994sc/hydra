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
  pname = "omni";
  version = "0.34.0";
  sha256 = "sha256-aYdJ1cfA2xov0JMGlKNTcLfpi3KX3jRRA6N+8WfQoi0=";
  vendorHash = "sha256-vJb9uUqLzQ38b4nJv0Q6/V8lIxw04fow16e2SSRCmuI=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "siderolabs";
    repo = "omni";
  };

  ldflags = [ "-s" ];

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o omnictl -ldflags "${args}" cmd/omnictl/main.go
    '';

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    install -dm755 $out/bin
    mv omnictl $out/bin/omnictl
    runHook postInstall
  '';

  postInstall = ''
    $out/bin/omnictl completion bash > omnictl.bash
    $out/bin/omnictl completion zsh  > omnictl.zsh
    $out/bin/omnictl completion fish > omnictl.fish
    installShellCompletion omnictl.{bash,zsh,fish}
  '';

  meta = with lib; {
    # keep-sorted start
    # keep-sorted end
  };
}
