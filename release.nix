{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc865" }:

let
  inherit (nixpkgs) pkgs;
  f = import ./default.nix;
  haskellPackages = if compiler == "default"
                    then pkgs.haskellPackages
                    else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};
in
  drv
