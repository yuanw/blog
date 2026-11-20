import VersoBlog

open Verso Genre Blog
open Template
open Verso.Output Html

open Verso.Output

instance [MonadLift m m'] [Monad m'] [MonadConfig m] : MonadConfig m' where
  currentConfig := do
    let x : Config ← (currentConfig : m Config)
    pure x

/--
Adds navigation breadcrumbs to a template, if the current path is at least as long as `threshold`.
-/
def breadcrumbs (threshold : Nat) : Template := do
  if (← read).path.size ≥ threshold then
    let some pathTitles ← parents (← read).site (← read).path.toList
      | pure .empty
    pure html%{
      <nav class="breadcrumbs" role="navigation">
        <ol>
          { crumbLinks pathTitles |>.map (html%{<li>{·}</li>}) }
        </ol>
      </nav>
    }
  else pure .empty
where
  crumbLinks (titles : List String) : List Html := go titles.length titles
  go
    | 0, xs | 1, xs => xs.map Lean.Html.text
    | _, [] => []
    | n+1, x::xs =>
      let path := String.join <| List.replicate n "../"
      html%{<a href={path}>{x}</a>} :: go n xs

  parents (s : Site) (path : List String) : OptionT TemplateM (List String) :=
    match s with
    | .page _ _ contents => dirParents contents path
    | .blog _ _ contents => blogParents contents path

  dirParents (d : Array Dir) : (path : List String) → OptionT TemplateM (List String)
    | [] => pure []
    | p :: ps => do
      match d.find? (·.name == p) with
      | some (.page _ _ txt contents) => (txt.titleString :: ·) <$> dirParents contents ps
      | some (.blog _ _ txt contents) => (txt.titleString :: ·) <$> blogParents contents ps
      | some (.static ..) | none => failure

  blogParents (posts : Array BlogPost) : (path : List String) → OptionT TemplateM (List String)
    | [] => pure []
    | _ :: _ :: _ => failure
    | [p] => do
      match ← posts.findM? (fun x => x.postName' <&> (· == p)) with
      | some post => pure [post.contents.titleString]
      | _ => failure
