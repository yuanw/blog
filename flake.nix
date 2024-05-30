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

        {

          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            programs.nixpkgs-fmt.enable = true;
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
