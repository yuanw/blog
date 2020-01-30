{ nixpkgs ? import <nixpkgs> {} , compiler ? "ghc865" }:
let
  inherit (nixpkgs) haskellPackages;
  myPackages = haskellPackages.callCabal2nix "project" ./blog.cabal  {};

  bootstrap = import <nixpkgs> { };
  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    rev = "7f35ed9df40f12a79a242e6ea79b8a472cf74d42";
    sha256 = "1wr6dzy99rfx8s399zjjjcffppsbarxl2960wgb0xjzr7v65pikz";
  };

  pinnedPkgs = import src { };
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
haskellPackages.shellFor {
  withHoogle = true;
  packages = p: [myPackages];
  buildInputs = with nixpkgs.haskellPackages;
    [ hlint
      ghcid
      cabal2nix
      stylish-haskell
      wai-app-static
      (all-hies.selection {selector = p: {inherit (p) ghc865; };})
    ] ++ [pinnedPkgs.cabal-install];
}
