#!/usr/bin/env bash
# Scaffold a new blog post: write Blog/Posts/<Name>.lean and wire it into
# Blog/Posts.lean, Main.lean, and Blog/Categories.lean.
#
#   ./new-post.sh MyNewPost "A title for the post" nix tmux
#   POST_DATE=2024-03-01 ./new-post.sh MyNewPost "A title" nix   # backdate
#
# The new post is a draft (draft := true); preview with `just drafts`, then
# delete that line to publish. Categories are matched against
# Blog/Categories.lean by slug, and created there if they are new.
set -euo pipefail

usage() { echo "usage: $0 <PascalCaseName> <title> [category ...]" >&2; exit 1; }
[ $# -ge 2 ] || usage

name=$1 title=$2
shift 2

posts=Blog/Posts/"$name".lean
[ -f "$posts" ] && { echo "error: $posts already exists" >&2; exit 1; }
case $name in
  [A-Z]*) ;;
  *) echo "error: name must be PascalCase, e.g. MyNewPost (got: $name)" >&2; exit 1 ;;
esac
case $name in
  *[!A-Za-z0-9]*) echo "error: name must be letters and digits only (got: $name)" >&2; exit 1 ;;
esac

# All anchors must exist before anything is written, so a failure leaves no
# half-wired post behind.
grep -q '^import Blog\.Posts\.' Blog/Posts.lean || { echo "error: no post imports in Blog/Posts.lean" >&2; exit 1; }
grep -q '^  "blog" Blog\.Posts with$' Main.lean || { echo "error: blog site block not found in Main.lean" >&2; exit 1; }
grep -q '^end Blog$' Blog/Categories.lean || { echo "error: Blog/Categories.lean shape changed" >&2; exit 1; }

# A category's def name is `tag` + its slug with non-alphanumerics dropped, so
# "nix-darwin" -> tagNixdarwin. Keep that in sync with Blog/Categories.lean.
# pairs is one "ref slug" per line, cats the Lean list body.
cats="" pairs=""
for c in "$@"; do
  low=$(printf '%s' "$c" | tr 'A-Z' 'a-z' | tr -s '[:space:]' '-')
  slug=$(printf '%s' "$low" | tr -cd 'A-Za-z0-9')
  [ -n "$slug" ] || { echo "error: category '$c' has no letters or digits" >&2; exit 1; }
  ref="tag$(printf '%s' "${slug:0:1}" | tr 'a-z' 'A-Z')${slug:1}"
  cats+="${cats:+, }$ref"
  pairs+="$ref $low"
  pairs+=$'\n'
done

date=${POST_DATE:-$(date +%F)}
case $date in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *) echo "error: POST_DATE must be YYYY-MM-DD (got: $date)" >&2; exit 1 ;;
esac
year=${date%%-*}
rest=${date#*-}
month=$((10#${rest%%-*}))
day=$((10#${rest#*-}))

title=${title//\\/\\\\}
title=${title//\"/\\\"}

{
  printf 'import VersoBlog\nimport Blog.Code\nimport Blog.Categories\nopen Verso Genre Blog\n\n'
  printf '#doc (Post) "%s" =>\n\n%%%%%%\n' "$title"
  printf 'authors := ["Yuan Wang"]\n'
  printf 'date := {year := %d, month := %d, day := %d}\n' "$year" "$month" "$day"
  printf 'draft := true\n'
  [ -z "$cats" ] || printf 'categories := [%s]\n' "$cats"
  printf '%%%%%%\n\nWrite the post here.\n'
} >"$posts"

# Imports go after the last existing post import.
last=$(grep -n '^import Blog\.Posts\.' Blog/Posts.lean | tail -1 | cut -d: -f1)
awk -v n="$last" -v imp="import Blog.Posts.$name" \
  '{ print } NR == n { print imp }' Blog/Posts.lean >Blog/Posts.lean.tmp
mv Blog/Posts.lean.tmp Blog/Posts.lean

# Main.lean lists posts newest-first, so the new one goes right below the
# "blog" Blog.Posts with marker.
awk -v e="    Blog.Posts.$name" '
  { print }
  !done && /^  "blog" Blog\.Posts with$/ { print e; done = 1 }
' Main.lean >Main.lean.tmp
mv Main.lean.tmp Main.lean

# Unknown categories are inserted into Blog/Categories.lean in def-name order.
while read -r ref slug; do
  [ -n "$ref" ] || continue
  grep -q "^def $ref : Category where$" Blog/Categories.lean && continue
  awk -v new=$(printf '%s' "$ref" | tr 'A-Z' 'a-z') \
      -v name="$slug" -v ref="$ref" '
    $1 == "def" && $2 ~ /^tag/ && !done {
      if (tolower($2) > new) { print block; done = 1 }
    }
    /^end Blog$/ && !done { print block; done = 1 }
    BEGIN { block = sprintf("def %s : Category where\n  name := \"%s\"\n  slug := \"%s\"\n", ref, name, name) }
    { print }
  ' Blog/Categories.lean >Blog/Categories.lean.tmp
  mv Blog/Categories.lean.tmp Blog/Categories.lean
  echo "created category $ref (slug: $slug)"
done <<<"$pairs"

echo "wrote $posts"
echo "next: edit $posts, then 'just drafts' to preview"
