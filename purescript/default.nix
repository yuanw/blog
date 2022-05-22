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
      esbuild --bundle ./output/Frontend/index.js --platform=browser --minify --outfile="frontend.js"
    '';
    installPhase = ''
      mkdir $out
      mv frontend.js $out/
    '';
  };

}
