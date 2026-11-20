/-
Syntax highlighting for code fences in languages other than Lean.

Verso highlights Lean only — fences are dispatched by name to registered
expanders, and every one of them is Lean-centric, so ```nix is an elaboration
error ("No registered code block `nix`"). These fences render plain
<pre><code class="language-X"> instead, and highlight.js — loaded by the theme
in Main.lean — colours them in the browser. With JavaScript off the code is
still readable, just uncoloured. An unnamed fence stays a plain <pre>.

The declaration name *is* the fence name, so these must not collide with a
category in Blog/Categories.lean or with VersoBlog's own `html` directive.
-/
import VersoBlog

open Verso Doc Elab Genre Blog
open Verso Output Html Template

/-- Run highlight.js over the fences once the page is parsed. Verso links this next to the
component's other assets, so it loads only on pages that actually use a fence. -/
private def hljsInit : String :=
  "document.addEventListener('DOMContentLoaded', function () { if (window.hljs) { hljs.highlightAll(); } });"

/-- One highlighted fence. `language` becomes the `language-` class highlight.js looks for. -/
block_component highlightedCode (language : String) (source : String) where
  toHtml _id _data _goI _goB _contents := do
    pure html%{<pre><code class={s!"language-{language}"}>{source}</code></pre>}
  jsFiles := #[("highlight.js", hljsInit)]

@[code_block]
meta def haskell : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "haskell" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def java : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "java" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def js : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "js" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def json : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "json" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def nix : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "nix" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def shell : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "shell" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def toml : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "toml" $(Lean.quote code.getVersoCodeBlock) #[])

@[code_block]
meta def yaml : CodeBlockExpanderOf Unit
  | (), code => ``(highlightedCode "yaml" $(Lean.quote code.getVersoCodeBlock) #[])
