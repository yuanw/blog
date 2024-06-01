---
title: Build a blog with Nix
pubDate: 'Sep 13, 2020'
modified: Sep 26, 2020
description: Using Hakyll, github action, and Firebase
tags: nix, haskell, hakyll
---


# Vision

I have been learning nix for a while. Overall, I am really happy with
Nix ecosystem. With Nix, home-manager, cachix, you have setup a reliable
and efficient development environment and CI. For demonstration, I want
to show you how I use nix to publish my blog:

-   compile a [Hakyll](https://jaspervdj.be/hakyll/) program
-   generate the static site using the Hayll program
-   Upload the site to Firebase

If you are new to Nix, I hope you can find something useful in this
blog.

## Why Nix ecosystem

Hopefully, at this point you are already sold on nix. If not, maybe
checkout [build with nix](https://builtwithnix.org/) or
[nix.dev](https://nix.dev). For me, the biggest selling point of is: you
can use a declarative language to set up a reproducible environment for
your local development and CI.

## Why Hakyll

This is probably a tough sell if you don't care about Haskell. Nowadays,
you use tools like Hugo, WordPress, or Jekyll to effortless setup a
static site. I love Haskell, and Hakyll gives me an opportunity to use
Haskell.

## Why Firebase

There are lots of decent alternative to Firebase for hosting a static
site. Just to list few

-   GitHub page
-   [aws](https://deptype.com/posts/2019-02-21-create-blog-nix-hakyll-aws.html)
    s3
-   [netlify](https://terrorjack.com/posts/2018-11-18-hello-world.html)
    seems really nice. probably worth trying out
-   Google cloud storage can
    [host](https://cloud.google.com/storage/docs/hosting-static-website)
    a static site, but currently it does not support SSL.

# Required Tools

-   [nix](https://nixos.org/manual/nix/stable/#chap-installation)
    (either single user or multi-user installation would work)
-   [direnv](https://direnv.net/) or
    [nix-direnv](https://github.com/nix-community/nix-direnv) recommend
    using [home-manager](https://github.com/nix-community/home-manager)
    to get
    [it](https://github.com/nix-community/home-manager/blob/master/modules/programs/direnv.nix))
-   [lorri](https://github.com/target/lorri) (optional, only if direnv
    by itself doesn't work well enough for you)
-   [cachix](https://cachix.org/) (optional)

# Consider using nix project template

-   [getting-started-nix-template](https://github.com/nix-dot-dev/getting-started-nix-template)
-   [hakyll-nix-template](https://github.com/rpearce/hakyll-nix-template)

Both templates are very opinionated.
[getting-started-nix-template](https://github.com/nix-dot-dev/getting-started-nix-template)
is a more generic nix template. hakyll-nix-template is Hakyll specified,
it has sitemap, tag support.

``` shell
.
├── content
|    ├── about.org
|    ├── contact.org
|    ├── css
|    ├── images
|    ├── index.html
|    ├── posts
|    └── templates
├── default.nix
├── nix
|   ├── default.nix
|   ├── sources.json
|   └── sources.nix
├── shell.nix
└── src
```

# scaffold hakyll project using `hakyll-init`

Hakyll comes with a command line too `haskyll-init` to scaffold a Hakyll
project. Since we only need `haskell-init` once, normal nix workflow
would be

``` shell
nix-shell -p pkgs.haskellPackages.hakyll
```

but depend on which nix channel is your default channel, you might get
an error about `pkgs.haskellPackages.hakyll` is broken. We could use
`-I` flag to pin our one-time shell package to stable version. The
pattern is
`-I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/{rev}.tar.gz~`

``` shell
~nix-shell -p pkgs.haskellPackages.hakyll -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/14006b724f3d1f25ecf38238ee723d38b0c2f4ce.tar.gz~
```

``` shell
hakyll-init . #scaffold at current directory
hakyll-init content  #scaffold at ./content directory
```

The project is just a plain cabal project. We can edit project or
executable name. We can use normal Nix Haskell development workflow.

# Nix Haskell Workflow

Currently, there are two major Nix Haskell workflows:
[iohk-haskell.nix](https://input-output-hk.github.io/haskell.nix/tutorials/development/)
and your traditional
[nixpgs](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/haskell.section.md).
People usually recommend iohk one for complex project, I haven't used it
at all.

``` shell
nix-shell -p cabal2nix # unless you already installed cabal2nix globally
cabal2nix . > blog.nix
```

``` nix
{ project ? import ./nix {}
}:
let
  haskellPackages = project.pkgs.haskellPackages;
  packages = haskellPackages.callCabal2nix "blog" ./blog.cabal {};
in
haskellPackages.shellFor {
  withHoogle = true;
  packages = p: [ packages ];
  buildInputs = builtins.attrValues project.devTools;
  shellHook = ''
    ${project.ci.pre-commit-check.shellHook}
  '';
}
```

<https://discourse.nixos.org/t/nix-haskell-development-2020/6170>
`hoogle server --local -p 3000 -n`

## How to find certain (Haskell) package's version

``` shell
nix repl
nix-repl> sources = import ./nix/sources.nix
nix-repl> pkgs = import sources.nixpkgs {}
nix-repl> pkgs.haskellPackages.hakyll.version
"4.13.0.1"
nix-repl> :q
```

# How to customize Hakyll

This is probably beyond the scope of this blog, Robert Pearce has an
on-going serial on the topic.
<https://robertwpearce.com/hakyll-pt-1-setup-and-initial-customization.html>

Here is a list of Hakyll projects I often check

-   <https://github.com/abhin4v/abhin4v.github.io/tree/source>
-   <https://github.com/sdiehl/stephendiehl.com>
-   <https://github.com/kowainik/kowainik.github.io/blob/develop/src/Kowainik.hs>
-   <https://github.com/ysndr/blog>
-   <https://github.com/patrickt/patrickt.github.io>
-   <https://github.com/rpearce/robertwpearce.com>

Hakyll website has a more comphersive
[list](https://jaspervdj.be/hakyll/examples.html)

# GitHub Action

## Build Step

Most of the YAML configuration is copied from
getting-started-nix-template. My `default.nix` only build the Hakyll
program, it doesn't generate the site. So I added
`result/bin/site build` in run command. (`site` is the name of my Hakyll
executable). We need pass generated site directory as
[artifacts](https://docs.github.com/en/free-pro-team@latest/actions/guides/storing-workflow-data-as-artifacts)
between build steps

``` yaml
- name: Archive Production Artifact
  uses: actions/upload-artifact@master
   with:
       name: dist
       path: dist
```

`dist` is the directory name for the generated site, by default Hakyll
uses `_site`.

## Publish to Firebase

I use [w9jds firebase action](https://github.com/w9jds/firebase-action)
to publish the generated static site directory to Firebase. There are
publish actions for netlify and Github Page. Of course, we have to store
our Firebase token as encrypted secret and pass them as environment
variables into the build step.

-   <https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets>
-   <https://github.com/w9jds/firebase-action#environment-variables>

## Enable cachix cache (Optional)

-   <https://nix.dev/tutorials/continuous-integration-github-actions.html>
-   <https://github.com/cachix/cachix-action>

Current version of GitHub Action YAML

``` yaml
name: CI

on:
  push:
    branches:
      - master

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2.3.4
    - uses: cachix/install-nix-action@v12
    - uses: cachix/cachix-action@v8
      with:
        name: yuanw-blog
        signingKey: ${{ secrets.CACHIX_SIGNING_KEY }}
    - name: Nix build
      run: |
        nix-build
        result/bin/site build
    - name: Archive Production Artifact
      uses: actions/upload-artifact@master
      with:
          name: dist
          path: dist

  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@v2.3.2
      - name: Download Artifact
        uses: actions/download-artifact@master
        with:
          name: dist
          path: dist
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@v1.5.0
        with:
          args: deploy --message '${{github.event.head_commit.message}}' --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
          PROJECT_ID: ${{secrets.FIREBASE_PROJECT_ID}}
```

# Result

Right now, the whole CI steps averagely takes 4 min to run. I am pretty
happy with the setup.

# References

## About Nix in general

-   <https://nix.dev/tutorials/index.html>

## Nix Haskell development

-   <https://github.com/Gabriel439/haskell-nix/>
-   <https://discourse.nixos.org/t/nix-haskell-development-2020/6170>
    (probably more up to date)

## Hakyll

-   <https://robertwpearce.com/hakyll-pt-6-pure-builds-with-nix.html>
-   <https://jaspervdj.be/hakyll/tutorials/github-pages-tutorial.html>

## Github Action

-   <https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions>
-   <https://nix.dev/tutorials/continuous-integration-github-actions.html>
-   <https://docs.github.com/en/free-pro-team@latest/actions/guides/storing-workflow-data-as-artifacts>
