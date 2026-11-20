/-
Margin notes, Tufte-style: the note floats into the right gutter next to the
text it annotates, numbered per page, and hides behind its own number on
narrow screens.

Author them inline with a role. The note is bracketed, not backticked — the
backticks are the code form (`{lit}`code`), the brackets are what gets parsed
as Markdown:

  … the paragraph text {sidenote}[the note, which may contain *markdown*] …

The note is inline content, so keep it to sentences; block-level notes would
need a `block_component … +directive` instead.
-/
import VersoBlog

open Verso Doc Elab Genre Blog
open Verso Output Html

/-- The layout lives here rather than in static_files/style.css so that a page
    without any sidenotes doesn't pay for it: Verso links this only for pages
    that use the role. -/
private def sidenoteCss : String :=
r#"
main .wrap { counter-reset: sidenote-counter; }

/* The theme caps bare paragraphs at the reading measure, but Verso wraps post
   content in <section>s, so those paragraphs keep the full frame width and a
   floated note would hang off the page. Reserve the gutter instead — only on
   the pages that actually have a note. */
main .wrap:has(.sidenote) { padding-right: 300px; }

/* The number in the text; it is also the <label> for the checkbox below, so
   clicking it toggles the note when the gutter is too narrow to show it. */
.sidenote-number {
  counter-increment: sidenote-counter;
  cursor: pointer;
}

.sidenote-number:after {
  content: counter(sidenote-counter);
  font-size: 0.72rem;
  font-weight: 700;
  vertical-align: super;
  line-height: 0;
  color: var(--signal-ink, #c2185b);
  margin-left: 0.1em;
}

/* The note itself, in the gutter to the right of the 760px text column. */
.sidenote {
  float: right;
  clear: right;
  width: 260px;
  margin-right: -300px;
  margin-top: 0.35rem;
  margin-bottom: 0;
  padding-left: 0.7rem;
  border-left: 2px solid var(--rule, #b4b7b9);
  font-size: 0.78rem;
  line-height: 1.35;
  color: var(--ink-soft, #2e3133);
  position: relative;
}

.sidenote p { margin: 0 0 0.5em; }
.sidenote p:last-child { margin-bottom: 0; }
.sidenote pre { overflow-x: auto; font-size: 0.92em; }

input.margin-toggle { display: none; }
label.sidenote-number { display: inline-block; max-height: 2rem; }

/* No :has() means no reserved gutter, so keep the note in the flow. */
@supports not (selector(:has(*))) {
  .sidenote {
    float: none;
    width: auto;
    margin: 0.6rem 0;
  }
}

@media (max-width: 1120px) {
  .sidenote {
    display: none;
    float: none;
    width: auto;
    margin: 0.6rem 0;
    border-left-width: 4px;
  }

  .margin-toggle:checked + .sidenote {
    display: block;
    width: 100%;
  }
}
"#

/-- Renders one sidenote: a numbered marker in the flow, a checkbox to fold the
    note behind on narrow screens, and the note itself. -/
inline_component sidenote where
  toHtml id _json goI contents := do
    pure html%{<label for={id} class="margin-toggle sidenote-number"></label><input type="checkbox" id={id} class="margin-toggle"/><span class="sidenote">{← contents.mapM goI}</span>}
  cssFiles := #[("sidenotes.css", sidenoteCss)]

/-- The Markdown role `{sidenote}[…]`. -/
@[role sidenote]
meta def sidenoteRole : RoleExpanderOf Unit
  | (), inls => do
    ``(sidenote #[$(← inls.mapM Verso.Doc.Elab.elabInline),*])
