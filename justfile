# Lets `new` hand its arguments to the script without the shell splitting the
# title or a multi-word category.
set positional-arguments

default:
    @just --list

# Scaffold a new draft post: just new MyPost "A title" nix tmux
new NAME TITLE *TAGS:
    ./new-post.sh "$@"

# Compile the Lean sources (Blog library + generate-blog)
compile:
    lake build

# Render the site into ./_site
build: compile
    lake exe generate-blog

# Render the site including drafts (draft := true in the post metadata)
drafts: compile
    lake exe generate-blog --drafts

# Render and serve ./_site on http://localhost:8000
serve: build
    python3 -m http.server -d _site 8000

# Publish the build closure (Lean, Lake deps, site, dev shell) to cachix
push-cache:
    ./push-cache.sh
