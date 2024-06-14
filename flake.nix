{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dream2nix_legacy.url = "github:nix-community/dream2nix/c9c8689f09aa95212e75f3108788862583a1cf5a";

    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  devenv.url = "github:cachix/devenv";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
           inputs.devenv.flakeModule
inputs.dream2nix_legacy.flakeModuleBeta
        ./mechanical-meridian/flake-module.nix
      ];
      perSystem = { self', lib, config, pkgs, ... }:

        {
packages.nodejs = pkgs.nodejs_22;

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
