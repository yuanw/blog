{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dream2nix.url = "github:nix-community/dream2nix";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, dream2nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.devenv.flakeModule
        ./mechanical-meridian/flake-module.nix
      ];
      perSystem = { self', lib, config, pkgs, ... }:

        {
          packages.nodejs = pkgs.nodejs_22;

          packages.dream-blog = dream2nix.lib.evalModules {
            packageSets.nixpkgs = pkgs;
            modules = [
              {
                imports = [
                     dream2nix.modules.dream2nix.nodejs-devshell-v3
                  # dream2nix.modules.dream2nix.nodejs-package-lock-v3
                  # dream2nix.modules.dream2nix.nodejs-granular-v3
                ];

                mkDerivation = {
                  src = ./mechanical-meridian;
                };

                deps = { nixpkgs, ... }: {
                  inherit
                    (nixpkgs)
                    fetchFromGitHub
                    stdenv
                    mkShell
                    rsync
                    cacert
                    ;
                };

                name = "dream-blog";
                version = "0.1.0";
              }
              {
                paths.projectRoot = ./.;
                # can be changed to ".git" or "flake.nix" to get rid of .project-root
                paths.projectRootFile = "flake.nix";
                paths.package = ./.;
              }
            ];

          };

          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            programs.nixpkgs-fmt.enable = true;
          };
          devenv.shells.default = {
            # https://devenv.sh/reference/options/
            packages = [
              config.treefmt.build.wrapper
              config.packages.nodejs

            ];

            scripts.preview.exec = ''
              npx http-server ${config.packages.blog}
            '';
          };

          packages.default = config.packages.blog;



        };
    };
}
