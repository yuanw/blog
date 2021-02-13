{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-20.09";
    flake-utils.url = "github:numtide/flake-utils/master";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = self: super: {
        haskellPackages = super.haskellPackages.override {
          overrides = hself: hsuper: {
            blog = hself.callCabal2nix "blog"
              (self.nix-gitignore.gitignoreSourcePure [
                ./.gitignore

              ] ./src) { };
          };
        };
        blog = self.haskell.lib.justStaticExecutables self.haskellPackages.blog;
      };
    in {
      inherit overlay;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        defaultPackage = pkgs.blog;
        devShell = pkgs.haskellPackages.shellFor {
          packages = p: [ p."blog" ];
          buildInputs = with pkgs.haskellPackages; [
            cabal-install
            ghcid
            ormolu
            hlint
            pkgs.nixpkgs-fmt
          ];
          withHoogle = false;
        };
      });
}
