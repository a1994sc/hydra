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
  pname = "talosctl";
  version = "1.7.1";
  sha256 = "sha256-3Fyy+8PjdSo12JwmaEa8qXwcT5ZriHyt5bTyyzV9eVw=";
  vendorHash = "sha256-kkhPXhjeL5XgahJj7TbmjhsZ50LVLsTQm5Ccp1v/of8=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "siderolabs";
    repo = "talos";

    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git describe --match=none --always --abbrev=8 > $out/COMMIT
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  ldflags = [
    "-s"
    "-w"
  ];

  GOEXPERIMENT = "loopvar";

  subPackages = [ "cmd/${pname}" ];

  preBuild = ''
    cat COMMIT | tr -d "\n" > pkg/machinery/gendata/data/sha
    export GOWORK="off"
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/talosctl completion $shell > talosctl.$shell
      installShellCompletion talosctl.$shell
    done
  '';

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "A CLI for out-of-band management of Kubernetes nodes created by Talos";
    homepage = "https://www.talos.dev/";
    license = licenses.mpl20;
    mainProgram = "talosctl";
    # keep-sorted end
  };
}
