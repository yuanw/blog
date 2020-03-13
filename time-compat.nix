{ mkDerivation, base, base-compat, base-orphans, deepseq, fetchgit
, HUnit, QuickCheck, stdenv, tagged, tasty, tasty-hunit
, tasty-quickcheck, time
}:
mkDerivation {
  pname = "time-compat";
  version = "1.9.2.2";
  src = fetchgit {
    url = "https://github.com/andersk/time-compat.git";
    sha256 = "11y1fkndcw8bkpfx3jwpbv6i9p0v7snavy2vi76sckkk0jp0rpq5";
    rev = "d8d82905d009c44e7e8148442d76820a5d51b1df";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [ base base-orphans deepseq time ];
  testHaskellDepends = [
    base base-compat deepseq HUnit QuickCheck tagged tasty tasty-hunit
    tasty-quickcheck time
  ];
  homepage = "https://github.com/phadej/time-compat";
  description = "Compatibility package for time";
  license = stdenv.lib.licenses.bsd3;
}
