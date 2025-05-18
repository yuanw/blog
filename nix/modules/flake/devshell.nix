{
  perSystem = { config, pkgs, lib, ... }:
    # Default shell.
    let
      shiki = pkgs.buildNpmPackage rec {
        pname = "shiki";
        version = "3.4.2";

        src = lib.fetchFromGitHub {
          owner = "shikijs";
          repo = "shiki";
          rev = "v${version}";
          hash = "sha256-J7H1oofgosFGxoHzcx+UxaRbqGwqrmk6MYmMISpNB6w=";
        };

        npmDepsHash = "sha256-/YWsk+GNfudSG0Rof1eCXeoK6dfyzzQqvWBLkpfahE0=";
      };
    in
    {
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
          shiki
          ghciwatch
          haskellPackages.wai-app-static
          haskellPackages.hakyll
        ];
      };
    };
}
