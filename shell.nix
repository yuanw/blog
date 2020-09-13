{ project ? import ./nix {}
}:
let
  myHaskellPackages = project.pkgs.haskellPackages;
  myPackages = myHaskellPackages.callCabal2nix "project" ./blog.cabal {};
in
myHaskellPackages.shellFor {
  withHoogle = true;
  packages = p: [ myPackages ];
  buildInputs = builtins.attrValues project.devTools;
  shellHook = ''
    ${project.ci.pre-commit-check.shellHook}
  '';
}
