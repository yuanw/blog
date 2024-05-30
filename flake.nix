{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.devshell.flakeModule
      ];
      perSystem = { self', lib, config, pkgs, ... }:
        let
          mkBlogContent = { includeDraft ? false }:
            pkgs.stdenv.mkDerivation {
              pname =
                if includeDraft then "blog-content-preview" else "blog-content";
              version = "0.0.4";
              buildInputs = [ pkgs.glibcLocales ];
              LANG = "en_US.UTF-8";
              PREVIEW = if includeDraft then "TRUE" else "FALSE";
              src = ./.;
              buildPhase = ''
                ${self'.packages.blog}/bin/blog rebuild
                mkdir $out
              '';
              installPhase = ''
                mv dist/* $out
              '';
            };
        in
        {

          packages.blogContent = mkBlogContent { };
          packages.draftContent = mkBlogContent { includeDraft = true; };

          haskellProjects.default = {
            projectRoot = ./src;
            autoWire = [ "packages" "apps" "checks" ]; # Wire all but the devShell
            devShell = {
              hlsCheck.enable = false;
            };
          };
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            programs.ormolu.enable = true;
            programs.nixpkgs-fmt.enable = true;
            programs.cabal-fmt.enable = true;
            programs.hlint.enable = true;
            # We use fourmolu
            programs.ormolu.package = pkgs.haskellPackages.fourmolu;
            settings.formatter.ormolu = {
              options = [ "--ghc-opt" "-XImportQualifiedPost" ];
            };
          };

          packages.default = config.packages.blogContent;
          devshells.default = {
      commands = [
        { package = config.packages.nodejs; category = "docs"; }
      ];
    };

        };
    };
}
