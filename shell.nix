{ project ? import ./nix {}
}:
let
  haskellPackages = project.pkgs.haskellPackages;
  packages = haskellPackages.callCabal2nix "blog" ./blog.cabal {};
in
haskellPackages.shellFor {
  withHoogle = true;
  packages = p: [ packages ];
  buildInputs = builtins.attrValues project.devTools;
  shellHook = ''
    ${project.ci.pre-commit-check.shellHook}
  '';
}
