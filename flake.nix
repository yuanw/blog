{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    # pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # systems = [ "x86_64-linux" ];
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        inputs.treefmt-nix.flakeModule
        # inputs.pre-commit-hooks-nix.flakeModule
        # inputs.flake-parts.flakeModules.easyOverlay
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

          haskellProjects.main = {
            packages = {
              blog.root = ./src;
            };
            
            devShell = {
              tools = hp:
                {
                  treefmt = config.treefmt.build.wrapper;
                } // config.treefmt.build.programs;
              hlsCheck.enable = true;
            };
          };
          # pre-commit.settings.hooks = {
          #   nixpkgs-fmt.enable = true;
          #   cabal-fmt.enable = true;
          #   fourmolu.enable = true;
          # };
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            flakeFormatter =
              false; # For https://github.com/numtide/treefmt-nix/issues/55

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
          mission-control.scripts = {
            docs = {
              description = "Start Hoogle server for project dependencies";
              exec = ''
                echo http://127.0.0.1:8888
                hoogle serve -p 8888 --local
              '';
              category = "Dev Tools";
            };
            fmt = {
              description = "Format the source tree";
              exec = config.treefmt.build.wrapper;
              category = "Dev Tools";
            };
            repl = {
              description = "Start the cabal repl";
              exec = ''
                cabal repl "$@"
              '';
              category = "Dev Tools";
            };
            preview = { exec = "warp -d ${config.packages.draftContent}"; };
          };
          devShells.default = pkgs.mkShell {
            inputsFrom =
              [ config.mission-control.devShell self'.devShells.main ];
          };
          # devShells.default = config.mission-control.installToDevShell (pkgs.mkShell
          #   {
          #     nativeBuildInputs = [
          #       pkgs.nixpkgs-fmt
          #       pkgs.pre-commit
          #     ];
          #     shellHook = ''
          #       ${config.pre-commit.installationScript}
          #     '';
          #   } // self'.devShells.main);
          # packages.default = self'.packages.main-blog;
          packages.default = config.packages.blogContent;
        };
    };
}
