{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    haskell-flake.url = "github:srid/haskell-flake";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts , ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.devenv.flakeModule
       # ./mechanical-meridian/flake-module.nix
      ];
      perSystem = { self', lib, config, pkgs, ... }:

        {
        

          

          treefmt.config = {
          
            package = pkgs.treefmt;
            programs.nixpkgs-fmt.enable = true;
          };
          devenv.shells.default = {
            # https://devenv.sh/reference/options/
            packages = [
              config.treefmt.build.wrapper
            ];

            scripts.preview.exec = ''
              npx http-server ${config.packages.blog}
            '';
          };

          packages.default = config.packages.blog;



        };
    };
}
