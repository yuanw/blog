{ sources ? import ./sources.nix
}:

let
  # default nixpkgs
  pkgs = import sources.nixpkgs {};

  # gitignore.nix
  gitignoreSource = (import sources."gitignore.nix" { inherit (pkgs) lib; }).gitignoreSource;

  src = gitignoreSource ./..;

  blog = pkgs.haskellPackages.callPackage ../blog.nix {};

  haskell-env = pkgs.haskellPackages.ghcWithHoogle (
    hp: with hp; [ cabal-install ] ++ blog.buildInputs
  );

  pre-commit-check = (import sources."pre-commit-hooks.nix").run {
    inherit src;
    hooks = {
      shellcheck.enable = true;
      nixpkgs-fmt.enable = true;
      nix-linter.enable = false;
      cabal-fmt.enable = true;
      ormolu.enable = true;
    };
    # generated files
    excludes = [ "^nix/sources\.nix$" ];
  };

in
{
  inherit pkgs src;
  # to be built by github actions
  ci = {
    blog = blog;
  };

  shell = pkgs.mkShell {
    name = "blog-env";
    buildInputs = with pkgs; [
      niv
      pre-commit
      nodejs
      hlint
      yarn
      yarn2nix
      haskell-env
    ];

    shellHook = ''
      ${pre-commit-check.shellHook}
      export HAKYLL_ENV="development"
      export HIE_HOOGLE_DATABASE="${haskell-env}/share/doc/hoogle/default.hoo"
      export NIX_GHC="${haskell-env}/bin/ghc"
      export NIX_GHCPKG="${haskell-env}/bin/ghc-pkg"
      export NIX_GHC_DOCDIR="${haskell-env}/share/doc/ghc/html"
      export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
    '';
  };
}
