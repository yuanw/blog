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
    hp: with hp; [ cabal-install ]
    ++ blog.buildInputs
  );
in
{
  inherit pkgs src;

  # provided by shell.nix
  devTools = {
    inherit (pkgs)
      niv
      pre-commit
      nodejs
      hlint
      yarn
      yarn2nix
      ;
  };


  # to be built by github actions
  ci = {
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
    blog = blog;
  };
}
