#!/usr/bin/env bash
# Publish this repo's build closure to lean4math.cachix.org: the Lean 4.36.0
# toolchain (built from the nixpkgs PR branch, so no public cache has it), the
# vendored Lake deps, the built site, and the dev shell. A fresh clone then
# substitutes instead of compiling Lean (~3 h).
# Needs CACHIX_AUTH_TOKEN in the env, or a prior `cachix authtoken ...`.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

nix build --no-link --print-out-paths .#default .#lake-deps .#site | cachix push lean4math
mkdir -p .direnv
nix develop --profile .direnv/push-profile -c true
cachix push lean4math .direnv/push-profile
