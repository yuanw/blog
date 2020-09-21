{ project ? import ./nix {}
}:

project.pkgs.mkShell {
  buildInputs = builtins.attrValues project.devTools ++ [ project.haskell-env ];
  shellHook = ''
    ${project.ci.pre-commit-check.shellHook}
  '';
}
