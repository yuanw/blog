# CLAUDE.md

This file provides guidance to AI coding agents when working with code in this
repository.

## Project Overview

Personal blog (https://yuanwang.ca/) built with [Verso](https://github.com/leanprover/verso),
the Lean 4 documentation tool. Posts are Lean files whose body is Markdown; the
site generator is a Lean executable (`Main.lean`) that Verso runs to emit HTML
into `_site/`. Nix flakes with [lean-flakes](https://github.com/yuanwang-wf/lean-flakes)
provide the toolchain — there is no elan, standalone Lean, or Haskell here.

## Build System

- `nix develop` (or `direnv allow`) — dev shell with `lean`, `lake` (a wrapper
  that resolves Lake's deps from the store) and `python3`
- `lake build` — compile the `Blog` library and the `generate-blog` executable
- `lake exe generate-blog` — render `./_site`
- `lake exe generate-blog --drafts` — also render posts with `draft := true`
- `just new MyPost "A title" nix tmux` — scaffold a draft post (`./new-post.sh`):
  writes `Blog/Posts/<Name>.lean` and registers it in `Blog/Posts.lean`, the
  `site` in `Main.lean`, and `Blog/Categories.lean` if a tag is new
- `just serve` — build, render, and serve `_site` on port 8000
- `just drafts` — same, including drafts
- `nix build .#site` — the rendered site in `result/` (what CI builds)
- `nix build .#default` — the Lake package from source (Lean + Verso + blog)
- `nix build .#lake-deps` — just the vendored Lake git dependencies; prints the
  `got:` hash to paste into `flake.nix`'s `lean.buildArgs.lakeHash` when the
  manifest changes
- `./push-cache.sh` — publish the build closure to lean4math.cachix.org
  (needs `CACHIX_AUTH_TOKEN`)

## Architecture

Everything is a Lake package at the repo root (`lakefile.toml`, package name
`yuan-blog`).

**`Main.lean`** — the site generator and the only theme:
- `theme` — the HTML `<head>`/`<header>`/`<footer>`, the font and highlight.js
  links (jsDelivr), and `/static/style.css`
- `blog` — the `site` DSL: front page, `static "static" ← "static_files"`, and
  the `"blog"` archive with the post list. Post order here is the order the
  archive lists them, so keep it newest-first. `main := blogMain theme blog`

**`Blog/`** — the content library (imported by `Blog.lean`):
- `Blog/Posts/<Name>.lean` — one post per file. `#doc (Post) "Title" =>` with a
  `%%%` metadata block (`authors`, `date`, `categories`, optional `draft :=
  true`) followed by Markdown
- `Blog/Posts.lean` — imports every post and defines the `"Archive"` page
- `Blog/Categories.lean` — tags as `Post.Category` values, prefixed `tag` (see
  below)
- `Blog/Code.lean` — code-fence expanders for non-Lean languages
- `Blog/Sidenotes.lean` — the `{sidenote}[…]` margin-note role (an `inline_component`
  that carries its own CSS)
- `Blog/Meta.lean` — `breadcrumbs` template helper
- `Blog/FrontPage.lean` — the front page

**`static_files/`** — served at `/static/` (currently `style.css` and `images/`).

## Markdown dialect

Verso's doc Markdown is close to CommonMark but not identical, and these bite:

- no indented code blocks — only fenced
- no autolinks — `<https://…>` is literal text, bare URLs are plain text; write
  `[text](url)`
- `_` inside link text is emphasis; escape it (`\_`) or shorten the link text
- ```` ```{=html} ```` and raw HTML are not supported
- empty image alt (`![](x.png)`) fails to parse
- footnotes (`[^1]`) need a definition and render as inline `<details>`; they
  can't be re-styled as margin notes without patching Verso's renderer
- a role's content in backticks is *code*; use brackets for markup
  (`{sidenote}[note with *markdown*]`)

## Code fences

Components (`inline_component` / `block_component … +directive`) are the way to
add new authoring syntax; `blogMain`'s component table is elaborated at its
call site in `Main.lean`, so the defining module must be imported there (via
`Blog.lean`).

Verso registers only Lean fences; anything else is an elaboration error unless
`Blog/Code.lean` defines it, and posts need `import Blog.Code` for the
registration to apply. The declaration name **is** the fence name, so a fence
called `nix` collides with a `def nix` category (categories are therefore
`tag`-prefixed) or with VersoBlog's own `html` directive.

## Versions

`lean-toolchain`, the Verso rev in `lakefile.toml`/`lake-manifest.json`, and the
nixpkgs pin in `flake.lock` must agree — lean-flakes asserts the toolchain
matches the Lean nixpkgs builds. Verso's tag tracks the Lean minor version.

## CI/CD

GitHub Actions (`.github/workflows/main.yml`): `nix build .#site` with the
public lean4math substituter (`accept-flake-config = true`), upload `dist/`,
deploy to Firebase Hosting on `master`. `firebase.json` also holds the 301s from
the old Hakyll URLs.
