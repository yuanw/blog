# yuanwang.ca

Source for [https://yuanwang.ca](https://yuanwang.ca), a
[Verso](https://github.com/leanprover/verso) blog built with
[lean-flakes](https://github.com/yuanwang-wf/lean-flakes): the Lean toolchain
and Lake come from nixpkgs, the build is reproducible, and Lake's git
dependencies are vendored by a fixed-output derivation instead of being fetched
mid-build. Only Nix (with flakes) is needed — no elan, no standalone Lean, no
Haskell.

## Write and preview

```sh
direnv allow                 # or: nix develop
lake build                   # compiles the Blog library and generate-blog
lake exe generate-blog       # renders ./_site
python3 -m http.server -d _site 8000   # http://localhost:8000
```

`just serve` does the last two in one go; `just drafts` also renders posts whose metadata says `draft := true`.

## Write a post

Posts are Lean files under `Blog/Posts/` whose content is Markdown. Scaffold one
with `just new MyPost "My post title" nix tmux` — the script behind it is
`./new-post.sh`, and `POST_DATE=2025-01-02 just new ...` backdates it. It writes
the post, registers it in `Blog/Posts.lean` **and** in the `site` in `Main.lean`
(Verso lists posts in the order they are given, newest first), and creates any
category `Blog/Categories.lean` doesn't have yet. New posts start as drafts, so
preview with `just drafts`, then delete `draft := true` to publish:

```lean
import VersoBlog
import Blog.Code          -- needed for the non-Lean code fences
import Blog.Categories

open Verso Genre Blog

#doc (Post) "My post title" =>

%%%
authors := ["Yuan Wang"]
date := {year := 2025, month := 1, day := 2}
draft := true
categories := [tagNix]
%%%

The post body, in Markdown.
```

The VS Code Lean extension needs `lean` and `LEAN_PATH` from the dev shell, so
start it from a direnv'd terminal.

## Code fences

Verso highlights Lean only. `Blog/Code.lean` registers fences for `haskell`,
`java`, `js`, `json`, `nix`, `shell`, `toml`, `yaml`; a post that uses one needs
`import Blog.Code`. They render as `<pre><code class="language-x">…` and the
theme in `Main.lean` loads highlight.js 11 (github-dark) from jsDelivr. An
unnamed fence stays plain `<pre>`.

Another language is two lines in `Blog/Code.lean` — the `language-` class is
what highlight.js switches on, so any language in its bundle works:

```lean
@[code_block]
meta def sql : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "sql" $(Lean.quote code.getVersoCodeBlock) #[])
```

The declaration name *is* the fence name, so it must not collide with a category
in `Blog/Categories.lean` (hence the `tag` prefix there) or with VersoBlog's own
`html` directive.

## Sidenotes

`Blog/Sidenotes.lean` adds a margin note that floats into the right gutter,
numbered per page, and folds behind its own number on narrow screens:

```markdown
The sentence I want to annotate {sidenote}[The note, which may contain
*markdown* — the brackets are parsed as inline Markdown.]
```

Brackets, not backticks: `` {role}`code` `` is Verso's code form (that's what
`{lit}`code` uses), so backticked content renders as `<code>` instead of
markup. Nothing uses the role yet, so `sidenotes.css` isn't linked until the
first note appears — Verso links a component's assets only on pages that use
it.

Markdown footnotes (`[^1]`) also work, but Verso renders them as inline
`<details>` and the renderer doesn't expose a hook for that node, so making
them margin notes would mean patching Verso.

## Reproducible build

```sh
nix build .#site           # the rendered HTML, in result/
nix build .#default        # lean 4.36.0 + verso + the blog, from the store
nix build .#lake-deps      # just the vendored Lake dependency tree
```

`nix build` needs no network beyond the substituters and the git clones in the
`lakeHash` derivation. The PR branch's `lean4` is not on any public cache, so
`push-cache.sh` publishes it (with the vendored Lake deps, the site and the dev
shell) to [lean4math.cachix.org](https://lean4math.cachix.org), which the flake
asks Nix to trust; a fresh clone then substitutes Lean instead of compiling it
(~3 h on an M-series Mac). `accept-flake-config = true` in nix.conf skips the
trust prompt.

## Layout

The Lake project sits at the repo root (`lakefile.toml`, `Main.lean`, `Blog/`,
`static_files/`) so that `lean-toolchain` and `lake-manifest.json` are next to
the lakefile, which is what lean-flakes expects for `lean.src`. Files under
`static_files/` are served at `/static/`.

## Versions

`lean-toolchain` must name exactly the Lean nixpkgs builds, or the flake refuses
to evaluate:

```
lean-flakes: .../lean-toolchain must contain exactly leanprover/lean4:v4.36.0
```

| thing | pin | why |
| --- | --- | --- |
| Lean | 4.36.0 | head of [NixOS/nixpkgs#587419](https://github.com/NixOS/nixpkgs/pull/587419) — nixpkgs master is still at 4.35.0 |
| Verso | `v4.36.0` tag, in `lakefile.toml` + `lake-manifest.json` | must match the Lean minor version |
| nixpkgs | `flake.lock` | moving it moves Lean |

The Lean 4.36.0 pin comes from an unmerged nixpkgs PR branch, so the flake pins
a fork. When it lands in nixpkgs-unstable, change `inputs.nixpkgs.url` back to
`github:NixOS/nixpkgs/nixos-unstable` and drop the `leanStage`/`doCheck`
overlay.

`nix flake update nixpkgs` moves Lean; update `lean-toolchain` and the Verso rev
to match, then refresh `lakeHash` (`nix build .#lake-deps` prints the `got:`
hash to paste in).

## Not included

Verso's blog genre has no RSS/Atom feed, so `/atom.xml` is gone (the old
Hakyll URL 404s). The old `/posts/*.html`, `/tags/*.html`, `/archive.html` and
`/images/*` URLs survive as 301s in `firebase.json`.
