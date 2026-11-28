{
  description = "Yuan's blog, built with Verso by lean-flakes (Lean 4.36.0, Lake git deps vendored)";

  inputs = {
    lean-flakes.url = "github:yuanw/lean-flakes";
    nixpkgs.follows = "lean-flakes/nixpkgs";
    flake-parts.follows = "lean-flakes/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      imports = [ inputs.lean-flakes.flakeModule ];

      perSystem = { config, pkgs, ... }: {
        lean = {
          src = ./.;
          # The `name` in lakefile.toml.
          packageName = "yuan-blog";
          # The posts use no Lean examples, so no Mathlib.
          mathlib = false;
          devShellPackages = [ pkgs.python3 ];

          buildArgs = {
            # Verso and its deps (subverso, MD4Lean, illuminate, plausible,
            # Cli) are not in nixpkgs' lean4Packages, so Lake's git deps are
            # cloned into a fixed-output derivation from lake-manifest.json.
            lakeHash = "sha256-nYNFxEXfBL9Kuk6KgVypa9XyrB1mexGS1Jmo+FRJ4yw=";
          };
        };

        # The vendored Lake dependency tree, so its hash can be refreshed on
        # its own (`nix build .#lake-deps`).
        packages.lake-deps = config.packages.default.passthru.computedLakeDeps;

        # The rendered site: `nix build .#site`, output in result/.
        # generate-blog reads static_files/ relative to the directory it runs
        # in, so it needs a writable copy of the sources.
        packages.site = pkgs.runCommand "yuan-blog-site" { src = ./.; } ''
          cp -r "$src" work
          chmod -R u+w work
          cd work
          export HOME="$TMPDIR"
          ${config.packages.default}/bin/generate-blog
          test -e _site/index.html
          cp -r _site "$out"
        '';
      };
    };

  # The Lean 4.36.0 toolchain comes from a nixpkgs PR branch, so only our own
  # cache (see push-cache.sh) has it. Nix asks once before trusting a new
  # substituter; `accept-flake-config = true` in nix.conf skips the prompt.
  nixConfig = {
    extra-substituters = [ "https://lean4math.cachix.org" ];
    extra-trusted-public-keys = [ "lean4math.cachix.org-1:lo4ur+c1M7f5i9VqM0YzEdZ1KpzXdlVqmFfrqfxmY5g=" ];
  };
}
