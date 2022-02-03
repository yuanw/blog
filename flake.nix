{
  description = "repo for Yuan's blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils/master";
    easy-ps = {
      url = "github:justinwoo/easy-purescript-nix/master";
      flake = false;
    };
    devshell.url = "github:numtide/devshell/master";
  };
  outputs = { self, nixpkgs, flake-utils, easy-ps, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = final: prev: {
          haskellPackages = prev.haskellPackages.override {
            overrides = hself: hsuper: {
              blog = (hself.callCabal2nix "blog"
                (final.nix-gitignore.gitignoreSourcePure [ ./.gitignore ] ./src)
                { });
            };
          };
          blog =
            final.haskell.lib.justStaticExecutables final.haskellPackages.blog;

          purs = (final.callPackage easy-ps { }).purs;
          spago = (final.callPackage easy-ps { }).spago;
          spago2nix = (final.callPackage easy-ps { }).spago2nix;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay overlay ];
        };
        myHaskellEnv = (pkgs.haskellPackages.ghcWithHoogle (p:
          with p;
          [ blog cabal-install ormolu hlint hpack brittany warp ]
          ++ pkgs.blog.buildInputs));
        spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
        # https://github.com/cideM/lions-backend/blob/main/client/default.nix#L40
        frontendJs = pkgs.stdenv.mkDerivation {
          name = "frontendJs";
          buildInputs =
            [ spagoPkgs.installSpagoStyle spagoPkgs.buildSpagoStyle ];
          nativeBuildInputs = with pkgs; [ purs spago ];
          src = ./.;
          unpackPhase = ''
            cp $src/spago.dhall .
            cp $src/packages.dhall .
            cp -r $src/halogen .
            install-spago-style
          '';
          buildPhase = ''
            build-spago-style ./halogen/*.purs
            spago bundle-app --no-install --no-build -m Frontend -t frontend.js --global-cache skip
          '';
          installPhase = ''
            mkdir $out
            mv frontend.js $out/
          '';
        };
        mkBlogContent = {includeDraft ? false}: pkgs.stdenv.mkDerivation {
          pname = if includeDraft then "blog-content-preview" else "blog-content";
          version = "0.0.2";
          buildInputs = [ pkgs.glibcLocales ];
          LANG = "en_US.UTF-8";
          PREVIEW = if includeDraft then "TRUE" else "FALSE";
          src = ./.;
          buildPhase = ''
            ${pkgs.blog}/bin/blog rebuild
            cp ${frontendJs}/frontend.js dist/js/frontend.js
            ${pkgs.nodePackages.tailwindcss}/bin/tailwindcss --input tailwind/tailwind.css -m -o dist/css/tailwind.css
            mkdir $out
          '';
          installPhase = ''
            mv dist/* $out
          '';
        };
        blogContent = mkBlogContent {};
        draftContent = mkBlogContent {includeDraft = true;};
      in {
        defaultPackage = blogContent;
        packages = flake-utils.lib.flattenTree {
          blogContent = blogContent;
          frontendJs = frontendJs;
        };
        apps.blog = flake-utils.lib.mkApp { drv = pkgs.blog; };
        devShell = pkgs.devshell.mkShell {
          name = "blog-dev-shell";
          imports = [ (pkgs.devshell.extraModulesDir + "/git/hooks.nix") ];
          git.hooks.enable = true;
          git.hooks.pre-commit.text = "${pkgs.treefmt}/bin/treefmt";
          bash = {
            extra = ''
              export LD_INCLUDE_PATH="$DEVSHELL_DIR/include"
              export LD_LIB_PATH="$DEVSHELL_DIR/lib"
            '';
            interactive = "";
          };
          commands = [
            {
              name = "cssWatch";
              category = "css";
              command =
                "ls tailwind/*.css | ${pkgs.entr}/bin/entr ${pkgs.yarn}/bin/yarn build";
            }
            {
              name = "preview";
              category = "static site";
              help = "preview static site files";
              command = "warp -d ${draftContent}";
            }
            {
              name = "siteClean";
              category = "static site";
              help = "clean static site files";
              command = "${pkgs.blog}/bin/blog clean";
            }
            {
              name = "siteWatch";
              category = "static site";
              help = "Watch static site files";
              command = "${pkgs.blog}/bin/blog watch";
            }
            {
              name = "yarn";
              category = "javascript";
              package = "yarn";
            }
            {
              name = "node";
              category = "javascript";
              package = "nodejs";
            }
            {
              name = "spago";
              category = "purescript";
              package = "spago";
            }
            {
              name = "spago2nix";
              category = "purescript";
              package = "spago2nix";
            }
            {
              name = "purs";
              category = "purescript";
              package = "purs";
            }
            {
              name = "entr";
              category = "utility";
              package = "entr";
            }
            {
              name = "buildJs";
              category = "purescript";
              help = "Build js from purescript";
              command =
                "spago bundle-app -m Frontend -t content/js/frontend.js";
            }
          ];
          # https://github.com/numtide/devshell/blob/master/modules/env.nix#L57
          env = [
            {
              name = "NODE_ENV";
              value = "development";
            }
            {
              name = "HIE_HOOGLE_DATABASE";
              value = "${myHaskellEnv}/share/doc/hoogle/default.hoo";
            }
            {
              name = "NIX_GHC";
              value = "${myHaskellEnv}/bin/ghc";
            }
            {
              name = "NIX_GHCPKG";
              value = "${myHaskellEnv}/bin/ghc-pkg";
            }
          ];
          packages = [
            myHaskellEnv
            pkgs.nixfmt
            pkgs.nodePackages.tailwindcss
            pkgs.treefmt
          ];
        };
      });
}
