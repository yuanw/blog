{ root, inputs, ... }:
{
  imports = [
    inputs.haskell-flake.flakeModule
  ];
  perSystem = { self', lib, config, pkgs, ... }: {
    # Our only Haskell project. You can have multiple projects, but this template
    # has only one.
    # See https://github.com/srid/haskell-flake/blob/master/example/flake.nix
    haskellProjects.default = {
      # To avoid unnecessary rebuilds, we filter projectRoot:
      # https://community.flake.parts/haskell-flake/local#rebuild
      projectRoot = builtins.toString (lib.fileset.toSource {
        inherit root;
        fileset = lib.fileset.unions [
          (root + /src)
          (root + /blog.cabal)
          # (root + /LICENSE)
          # (root + /README.md)
        ];
      });

      # The base package set (this value is the default)
      # basePackages = pkgs.haskellPackages;

      # Packages to add on top of `basePackages`
      packages = {
        pandoc-sidenote = {
          source = (builtins.fetchGit {
            url = "https://github.com/jez/pandoc-sidenote";
            rev = "3658e7da9453fb6ab817d8eef5d1928cbcd3afbf";
          });
          cabalFlags.html-sidenotes = true;
        };

        # Add source or Hackage overrides here
        # (Local packages are added automatically)
        /*
        aeson.source = "1.5.0.0" # Hackage version
        shower.source = inputs.shower; # Flake input
        */
      };

      # Add your package overrides here
      settings = {
        blog = {
          # stan = true;
          # haddock = false;
        };
        /*
        aeson = {
          check = false;
        };
        */
      };

      # Development shell configuration
      devShell = {
        hlsCheck.enable = false;
      };

      # What should haskell-flake add to flake outputs?
      autoWire = [ "packages" "apps" "checks" ]; # Wire all but the devShell
    };

    # Default package & app.
    packages.default = pkgs.stdenv.mkDerivation rec {
      name = "blog";
      version = "0.0.3";
      buildInputs = with pkgs; [
        (python3.withPackages (p: [
          p.pygments
        ]))

      ];
      src = builtins.path { path = ../../../.; name = "source"; };
      buildPhase = ''
        ls
        ${self'.packages.blog}/bin/blog build;
        


      

        mkdir $out


      '';


      installPhase = ''


                mv dist/* $out


              '';


    };
    apps.default = self'.apps.blog;
  };
}
