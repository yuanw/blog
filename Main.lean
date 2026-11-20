import VersoBlog

import Blog

open Verso Genre Blog Site Syntax

open Output Html Template Theme in
def theme : Theme := { Theme.default with
  primaryTemplate := do
    let postList :=
      match (← param? "posts") with
      | none => Html.empty
      | some html => html%{<h2>Posts</h2>} ++ html
    let catList :=
      match (← param? (α := Post.Categories) "categories") with
      | none => Html.empty
      | some ⟨cats⟩ => html%{
          <div class="category-directory">
            <h2>Categories</h2>
            <ul>
            { cats.map fun (target, cat) =>
              html%{<li><a href={target}>{Post.Category.name cat}</a></li>}
            }
            </ul>
          </div>
        }
    return html%{
      <html>
        <head>
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1"/>
          <meta name="color-scheme" content="light"/>
          <meta name="theme-color" content="#c9cbcc"/>
          <meta name="description" content="Yuan Wang's blog — notes on Nix, programming, and software engineering"/>
          <meta property="og:title" content={← param (α := String) "title"}/>
          <meta property="og:site_name" content="Yuan Wang's Blog"/>
          <title>{← param (α := String) "title"} — Yuan Wang's Blog</title>
          <link rel="preconnect" href="https://cdn.jsdelivr.net"/>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fontsource-variable/funnel-sans@5/index.css"/>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fontsource-variable/sometype-mono@5/index.css"/>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/styles/github-dark.min.css"/>
          <link rel="stylesheet" href="/static/style.css"/>
          {← builtinHeader}
        </head>
        <body>
          <header>
            <div class="inner-wrap">
            { if (← currentPath).isEmpty then .empty else
              html%{<a class="logo" href="/"><h1>Yuan Wang's Blog</h1></a>} }
            {← topNav}
            </div>
          </header>
          <main>
            <div class="wrap">
              {← breadcrumbs 2}
              {← param "content"}
              {catList}
              {postList}
            </div>
          </main>
          <footer>
            <div class="wrap">
              <p>Built with <a href="https://github.com/leanprover/verso">Verso</a> and <a href="https://nixos.org">Nix</a>.</p>
            </div>
          </footer>
          <!-- highlight.min.js is the common subset (bash, xml, plaintext), so
               the languages Blog/Code.lean fences need are loaded separately -->
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/highlight.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/nix.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/haskell.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/java.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/yaml.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/json.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.11.1/languages/ini.min.js"></script>
        </body>
      </html>
    }
  }
  |>.override #[] {
    template := do
      return html%{<div class="frontpage">{← param "content"}</div>},
    params := id
  }


def blog : Site := site Blog.FrontPage /
  static "static" ← "static_files"
  "blog" Blog.Posts with
    Blog.Posts.SpringR2dbcBatch
    Blog.Posts.ZipVoidReactor
    Blog.Posts.TmuxNix
    Blog.Posts.WireGitHookWithTreefmtAndDevshell
    Blog.Posts.GettingStartedWithFlakes
    Blog.Posts.PushDockerImageToGcrWithNix
    Blog.Posts.BuildBlogWithNix
    Blog.Posts.EglotMultipleJaveVersions
    Blog.Posts.WallyOnNixos
    Blog.Posts.MonoCache
    Blog.Posts.EmbraceNixFurther
    Blog.Posts.InstallNixos
    Blog.Posts.NixMacosDotfiles
    Blog.Posts.HakyllDraftDir


def main := blogMain theme blog
