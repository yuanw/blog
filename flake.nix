{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-20.09";
    flake-utils.url = "github:numtide/flake-utils/master";
    easy-ps.url = "github:justinwoo/easy-purescript-nix/master";
    easy-ps.flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, easy-ps }:
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
      };
    in {
      inherit overlay;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        purs = (import easy-ps { inherit pkgs; }).purs;
        spago = (import easy-ps { inherit pkgs; }).spago;

        cssDev = pkgs.writeShellScriptBin "cssDev"
          "ls tailwind/*.css|NODE_ENV=development entr yarn build";
      in rec {
        defaultPackage = pkgs.blog;
        apps.blog = flake-utils.lib.mkApp { drv = pkgs.blog; };
        defaultApp = apps.blog;
        devShell = pkgs.haskellPackages.shellFor {
          packages = p: [ p."blog" ];
          buildInputs = with pkgs.haskellPackages; [
            cabal-install
            ghcid
            ormolu
            hlint
            pkgs.nixpkgs-fmt

            pkgs.nodejs
            pkgs.yarn
            pkgs.entr
            cssDev

            purs
            spago
          ];
          withHoogle = false;
        };
      });
}
