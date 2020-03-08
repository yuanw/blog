{ mkDerivation, base, base-compat, hakyll, pandoc, stdenv }:
mkDerivation {
  pname = "blog";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base base-compat hakyll pandoc ];
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
