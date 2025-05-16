{
  perSystem = { config, pkgs, ... }: {
    # Default shell.
    devShells.default = pkgs.mkShell {
      name = "blog-dev-shell";
      meta.description = "Haskell development environment";
      # See https://community.flake.parts/haskell-flake/devshell#composing-devshells
      inputsFrom = [
        config.haskellProjects.default.outputs.devShell # See ./nix/modules/haskell.nix
        config.pre-commit.devShell # See ./nix/modules/formatter.nix
      ];
      packages = with pkgs; [
        just
        nixd
        ghciwatch
        haskellPackages.wai-app-static
        haskellPackages.hakyll
      ];
    };
  };
}
