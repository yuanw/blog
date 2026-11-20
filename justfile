default:
    @just --list

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
