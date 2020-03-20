{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc882" }:
let
  bootstrap = import <nixpkgs> {};

  nixpkgs = builtins.fromJSON (builtins.readFile ./nixpkgs.json);

  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  };

  pkgs = import src {};
  myHaskellPackages = pkgs.haskell.packages."${compiler}".override {
    overrides = self: super: rec {
      time-compat = self.callPackage ./time-compat.nix {};
    };
  };

  myPackages = myHaskellPackages.callCabal2nix "project" ./blog.cabal {};
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
myHaskellPackages.shellFor {
  withHoogle = true;
  packages = p: [ myPackages ];
  inherit ((import ./pre-commit.nix).pre-commit-check) shellHook;
  buildInputs = with myHaskellPackages;
    [
      hlint
      ghcid
      cabal2nix
      stylish-haskell
      cabal-install
      wai-app-static
      (all-hies.selection { selector = p: { inherit (p) ghc882; }; })
    ] ++ [ bootstrap.nodejs ];
}
