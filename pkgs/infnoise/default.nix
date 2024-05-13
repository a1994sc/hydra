{
  # keep-sorted start
  fetchFromGitHub,
  infnoise,
  lib,
  libftdi,
  stdenv,
  testers,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version, prefix_order=pname,version,
  pname = "infnoise";
  version = "0.3.3";
  sha256 = "sha256-UUtVb5So0v+aziWN01lkKdeK+3BFONNBdpzBgx+e8cw=";
  # keep-sorted end
  rev = version;
in
stdenv.mkDerivation rec {
  inherit version pname;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "leetronics";
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  preBuild = ''
    export GIT_COMMIT=$(cat COMMIT)
    export GIT_DATE=$(cat SOURCE_DATE_EPOCH)
  '';

  patches = [
    # Patch makefile so we can set defines from the command line instead of it depending on .git
    ./makefile.patch
  ];

  GIT_COMMIT = src.rev;
  GIT_VERSION = version;

  buildInputs = [ libftdi ];

  makefile = "Makefile.linux";
  makeFlags = [ "PREFIX=$(out)" ];
  postPatch = ''
    cd software
    substituteInPlace init_scripts/infnoise.service --replace "/usr/local" "$out"
  '';

  postInstall = ''
    make -C tools
    find ./tools/ -executable -type f -exec \
      sh -c "install -Dm755 {} $out/bin/infnoise-\$(basename {})" \;
  '';

  passthru = {
    tests.version = testers.testVersion { package = infnoise; };
  };

  meta = with lib; {
    # keep-sorted start
    description = "Driver for the Infinite Noise TRNG";
    homepage = "https://github.com/leetronics/infnoise";
    license = licenses.cc0;
    platforms = platforms.linux;
    # keep-sorted end
    longDescription = ''
      The Infinite Noise TRNG is a USB key hardware true random number generator.
      It can either provide rng for userland applications, or provide rng for the OS entropy.
    '';
  };
}
