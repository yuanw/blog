{ pkgs }:

let spagoPkgs = import ./spago-packages.nix { inherit pkgs; };

in {
  # https://github.com/cideM/lions-backend/blob/main/client/default.nix#L40
  frontendJs = pkgs.stdenv.mkDerivation {
    name = "frontendJs";
    buildInputs = [ spagoPkgs.installSpagoStyle spagoPkgs.buildSpagoStyle ];
    nativeBuildInputs = with pkgs; [ purs spago esbuild ];
    src = ./.;
    unpackPhase = ''
      cp $src/spago.dhall .
      cp $src/packages.dhall .
      cp -r $src/src .
      install-spago-style
    '';
    buildPhase = ''
      build-spago-style "./src/**/*.purs"
      ${pkgs.spago}/bin/spago --global-cache=skip -V bundle-app
    '';
    installPhase = ''
      mkdir $out
      mv frontend.js $out/
    '';
  };

}
