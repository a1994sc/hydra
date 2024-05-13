{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  runCommand,
  yq-go,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "yq-go";
  version = "4.44.1";
  sha256 = "sha256-5l948J0NTeWOeUMlcoEQZws8viqtARdkJsGch4c6Trw=";
  vendorHash = "sha256-j5vcx5wW2v1kNc2QCPR11JEb1fTA9q4E4mbJ2VJC37A=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "mikefarah";
    repo = "yq";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/yq shell-completion $shell > yq.$shell
      installShellCompletion yq.$shell
    done
  '';

  passthru.tests = {
    simple = runCommand "${pname}-test" { } ''
      echo "test: 1" | ${yq-go}/bin/yq eval -j > $out
      [ "$(cat $out | tr -d $'\n ')" = '{"test":1}' ]
    '';
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/mikefarah/yq/raw/v${version}/release_notes.txt";
    description = "Portable command-line YAML processor";
    homepage = "https://mikefarah.gitbook.io/yq/";
    license = [ licenses.mit ];
    mainProgram = "yq";
    # keep-sorted end
  };
}
