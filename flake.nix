{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-20.09";
    flake-utils.url = "github:numtide/flake-utils/master";
    easy-ps = {
      url = "github:justinwoo/easy-purescript-nix/master";
      flake = false;
    };
    inputs.devshell.url = "github:numtide/devshell/master";
  };
  outputs = { self, nixpkgs, flake-utils, easy-ps, devshell }:
    let
      overlay = self: super: {

        haskellPackages = super.haskellPackages.override {
          overrides = hself: hsuper: {
            blog = hself.callCabal2nix "blog"
              (self.nix-gitignore.gitignoreSourcePure [
                ./.gitignore

              ] ./src) { };
          };
        };
        blog = self.haskell.lib.justStaticExecutables self.haskellPackages.blog;
        purs = (import easy-ps { pkgs = self; }).purs;
        spago = (import easy-ps { pkgs = self; }).spago;
      };
    in {
      inherit overlay;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        cssDev = pkgs.writeShellScriptBin "cssDev"
          "ls tailwind/*.css|NODE_ENV=development entr yarn build";
      in rec {
        defaultPackage = pkgs.blog;
        apps.blog = flake-utils.lib.mkApp { drv = pkgs.blog; };
        defaultApp = apps.blog;
        devShell = pkgs.haskellPackages.shellFor {
          packages = p: [ p."blog" ];
          buildInputs = with pkgs;
            with pkgs.haskellPackages; [
              cabal-install
              ghcid
              ormolu
              hlint
              nixpkgs-fmt

              nodejs
              yarn
              entr
              cssDev

              purs
              spago
            ];
          withHoogle = false;
        };
      });
}
