{
  inputs = {
    # keep-sorted start block=yes case=no
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    # keep-sorted end
  };
  outputs =
    {
      # keep-sorted start
      flake-utils,
      nixpkgs,
      self,
      systems,
      treefmt-nix,
      # keep-sorted end
      ...
    }:
    let
      hydra =
        { system }:
        {
          hydraJobs.packages.${system} = self.packages.${system};
        };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs (
          { pkgs, ... }:
          {
            # keep-sorted start block=yes prefix_order=projectRootFile,
            projectRootFile = "flake.nix";
            programs.deadnix.enable = true;
            programs.keep-sorted.enable = true;
            programs.nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };
            programs.statix.enable = true;
            # Disabled on "flake.nix" because of some false positivies.
            settings.formatter.deadnix.excludes = [ "**/flake.nix" ];
            # keep-sorted end
          }
        );
      in
      with pkgs;
      {
        formatter = treefmtEval.config.build.wrapper;
        packages = nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./pkgs;
        };
      }
    )
    // {
      overlays = nixpkgs.lib.packagesFromDirectoryRecursive {
        callPackage = path: overrides: import path;
        directory = ./overlays;
      };
    }
    // hydra { system = "x86_64-linux"; };
}
