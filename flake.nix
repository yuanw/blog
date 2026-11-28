{
  description = "Yuan's blog, built with Verso by lean-flakes (Lean 4.36.0, Lake git deps vendored)";

  inputs = {
    # Lean 4.36.0 is not in nixpkgs yet (master is at 4.35.0); this is the head
    # of NixOS/nixpkgs#587419, which bumps lean4 and renames leanPackages to
    # lean4Packages. lean-flakes' module still uses the `leanPackages` alias,
    # which nixpkgs keeps with a warning. Re-pin to nixpkgs-unstable once that
    # PR lands.
    nixpkgs.url = "github:alejo7797/nixpkgs/lean4-4.36";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lean-flakes.url = "github:yuanwang-wf/lean-flakes";
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      imports = [ inputs.lean-flakes.flakeModule ];

      perSystem = { config, system, pkgs, ... }: {
        # Lean builds its own bootstrap three times over (stage0 -> stage2) and
        # runs its whole ctest suite: hours we don't need to render a blog.
        # stage1 already gives a working lean and lake.
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [ (final: prev: {
            lean4 = (prev.lean4.override { leanStage = 1; }).overrideAttrs (_: { doCheck = false; });
          }) ];
        };

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
