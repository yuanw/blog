# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal blog (https://yuanwang.ca/) built with Hakyll, a Haskell static site generator. The project uses Nix flakes for reproducible builds and development environments.

## Build System

### Nix-based Workflow

The project uses Nix flakes with `haskell-flake` and `nixos-unified`:
- `nix build` - Build the entire blog site (output in `result/`)
- `nix develop` - Enter development shell with all dependencies

The build is defined in `nix/modules/flake/haskell.nix`, which:
- Compiles the Haskell site generator (`blog.cabal`)
- Includes a custom `pandoc-sidenote` package from source
- Requires Python with Pygments for syntax highlighting
- Outputs the static site to `dist/`

### Development Commands

Using `just` (see `justfile`):
- `just serve` - Clean, build, and serve the site locally with `warp` (serves `_site/`)
- `just run` - Auto-recompile and run with `ghcid`
- `just repl` - Start `cabal repl`
- `just docs` - Run local Hoogle documentation server on port 8888

Direct cabal commands:
- `cabal run blog build` - Build the static site
- `cabal run blog clean` - Clean build artifacts
- `cabal run blog watch` - Watch mode for development

## Architecture

### Entry Point

`src/site.hs` - Single-file Hakyll site generator with custom transformations:

**Key Configuration:**
- `config`: Hakyll configuration (destination: `dist/`, preview port: 5000, source: `content/`)
- `postsPattern`: Matches `posts/*.org` and `posts/*.md` (includes `drafts/` when `PREVIEW=TRUE` env var is set)

**Content Processing Pipeline:**
1. Pandoc reads Org-mode or Markdown from `content/`
2. `myPandocCompiler` applies custom transformations:
   - `usingSideNotesHTML` - Converts footnotes to sidenotes (from `pandoc-sidenote`)
   - `pygmentsHighlight` - Syntax highlights code blocks via external Pygments call
3. Templates from `content/templates/` are applied
4. Output written to `dist/`

**Special Features:**
- Tag support with automatic tag pages (`content/tags/*.html`)
- Atom feed generation (`atom.xml` with 10 most recent posts)
- Archive page listing all posts
- CNAME file generation for custom domain

### Content Structure

- `content/posts/` - Published posts (.org and .md)
- `content/drafts/` - Drafts (only built when `PREVIEW=TRUE`)
- `content/templates/` - Hakyll templates (default.html, post.html, etc.)
- `content/css/`, `content/js/`, `content/images/` - Static assets

### Syntax Highlighting

Code blocks are highlighted using Pygments (not Pandoc's built-in highlighting):
- `pygmentsHighlight` function in `site.hs:93-100` shells out to `pygmentize`
- Python with Pygments must be available at build time
- Configured in both devShell and build derivation

## Code Quality

Pre-commit hooks (via `nix/modules/flake/pre-commit.nix`):
- `fourmolu` - Haskell formatter with ImportQualifiedPost support
- `hlint` - Haskell linter
- `cabal-fmt` - Cabal file formatter
- `nixpkgs-fmt` - Nix code formatter

Fourmolu settings: 2-space indentation, leading comma style, diff-friendly imports.

## CI/CD

GitHub Actions (`.github/workflows/main.yml`):
1. Build with `nix build` using Cachix for caching
2. Upload build artifacts
3. Deploy to Firebase Hosting on `master` branch pushes

## Extension Points

To modify post rendering:
- Edit `myPandocCompiler` in `site.hs:78-83`
- Add Pandoc AST transformations (see `addSectionLinks` for example)
- Modify `myWriter` to enable/disable table of contents

To add new content types:
- Add new `match` patterns in `main` function (after `site.hs:111`)
- Define routes and compilation rules following existing patterns
