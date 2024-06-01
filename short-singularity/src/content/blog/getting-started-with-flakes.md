---
title: Getting started with Nix Flakes and devshell
pubDate: 'Feb 13, 2021'
modified: Feb 16, 2021
description: My experience with Nix Flakes and devshell
tags: nix, Flakes
---

# Introduction

I finally converted my blog project to use Nix Flakes and
[numtide/devshell](https://github.com/numtide/devshell). I want to write
down what I learnt about Nix Flakes and devshell.

# What is Nix Flakes and Why you might care about it

Nix Flakes are a set of experimental features in the Nix package
manager.

If you are not familiar with `Flakes` yet, here is a list of resources
on it.

-   [Nix Wiki On Flakes](https://nixos.wiki/wiki/Flakes)

-   [zimbatm's article on Flakes](https://zimbatm.com/NixFlakes)

-   Nix Flakes Series on tweag.io by Eelco himself

    -   [Part I](https://www.tweag.io/blog/2020-05-25-flakes/)
    -   [Part II](https://www.tweag.io/blog/2020-06-25-eval-cache/)
    -   [Part III](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)

-   [NixCon 2019 Nix Flakes - Eelco
    Dolstra](https://www.youtube.com/watch?v=UeBX7Ide5a0)

-   [Jörg Thalheim Nix Flakes
    101](https://www.youtube.com/watch?v=QXUlhnhuRX4&list=PLgknCdxP89RcGPTjngfNR9WmBgvD_xW0l)

    the most content of this article is a rehash on these listed
    contents.

Some of goals of Flakes are

-   Standardized how we compose `nix` files and provide a single
    entry-point (You don't have to have `default.nix`, `ci.nix`,
    `shell.nix`, of course you can break down your flake file into
    smaller nix files).

-   Standardized nix packages' dependency management (I think with
    Flakes, one doesn't need [niv](https://github.com/nmattia/niv) to
    pin down dependencies version. Although niv is great, and its
    commands are more user friendly than what Flakes offers right now)

-   a set of more user friendly nix commands (nix run, nix develop)

-   better reproducibility

# How to install/uninstall Flakes

## install

Right now, Nix Flakes is not enabled by default. We need to explicitly
enable it.

### NixOS

adding the following in the `configuration.nix`

``` nix
{ pkgs, ... }: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
```

### non-NixOS

``` shell
nix-env -iA nixpkgs.nixFlakes
```

and add

``` shell
experimental-features = nix-command flakes
```

to `~/.config/nix/nix.conf` (if current shell user is nix trusted users)
or `/etc/nix/nix.conf`

Install Nix Flakes installer I am not sure whether this step is still
needed

``` shell
sh <(curl -L https://github.com/numtide/nix-flakes-installer/releases/download/nix-2.4pre20210126_f15f0b8/install)
```

You can type `nix-env --version` to verify. The Flakes version should
looks like `nix-env (Nix) 2.4pre20210126_f15f0b8`. (the version was 3.0,
and version rollbacked to 2.4)

## uninstall

### NixOS

just revert the change in `configuration.nix` and do
`nixos-rebuild switch`

### non-NixOS

`nix-env -iA nixpkgs.nix` should bring out `nix` to the mainline
version, and we need to revert the `nix.conf` change. Of course,
multi-user version needs to restart `nix-daemon`.

# How to bootstrap a Nix Flakes project

use `nix flake init` to generate the `flake.nix`, `nix flake update` to
generate `flake.lock` file.

An important thing about Flakes, to improve the reproducibility, Flakes
requires us to git staging all the `flake.nix` changes.

# (Selective) Anatomy of `flake.nix`

Beside `description`, `flake.nix` has 2 top-level attributes

-   `inputs` (the dependency management part)
-   `outputs` the function takes the all inputs we defined and evaluate
    a set of attributes. (Usually our build artifacts).

## inputs

a typical input might look like

``` nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils/master";
  };
}
```

here, it declares two dependencies `nixpkgs` and `flake-utils`. We can
use `nix flake update` to lock down dependencies.

We can point to a branch:
`inputs.nixpkgs.url = "github:Mic92/nixpkgs/master";`.

or revision:
`inputs.nix-doom-emacs.url = "github:vlaci/nix-doom-emacs?rev=238b18d7b2c8239f676358634bfb32693d3706f3";`

for non-Flakes dependency, we need to declare that.

``` nix
{
  inputs.bar.url = "github:foo/bar/branch";
  inputs.bar.flake = false;
}
```

Further, we can override a Flake dependency's input

``` nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
}
```

## outputs

### Schema

I skipped all the `nixos` related attributes.

    { self, ... }@inputs:
    {
      # Executed by `nix flake check`
      checks."<system>"."<attr>" = derivation;
      # Executed by `nix build .#<name>`
      packages."<system>"."<attr>" = derivation;
      # Executed by `nix build .`
      defaultPackage."<system>" = derivation;
      # Executed by `nix run .#<name>`
      apps."<system>"."<attr>" = {
        type = "app";
        program = "<store-path>";
      };
      # Executed by `nix run . -- <args?>`
      defaultApp."<system>" = { type = "app"; program = "..."; };
    }

where

-   `<system>` is the name of the platform, such as
    "x86<sub>64</sub>-linux", "x86<sub>64</sub>-darwin"
-   `<attr>` is the attribute name (package name)
-   `<store-path>` is a `/nix/store...` path

So for each `<attr>`, we can have

-   check (prerequisites for build the package)
-   package
-   app (executable)

and we can define a default `<attr>`.

## [flake-utils](https://github.com/numtide/flake-utils)

`flake-utils` ,as its name indicates, is a utility package help us write
flake.

For example, it has
[`eachDefaultSystem`](https://github.com/numtide/flake-utils/blob/3982c9903e93927c2164caa727cd3f6a0e6d14cc/default.nix#L60)
function take a lambda and iterate through all the systems supported by
nixpkgs an hydra. So we can reuse the same lambda to build for different
systems.

Using `flake-utils.lib.eachSystem [ "x86_64-linux" ]`, you target fewer
systems.

`flattenTree` takes a tree of attributes and flatten them into a one
level key-value (attribute to derivation), which is what Flakes packages
outputs expects.

`flattenTree { hello = pkgs.hello; gitAndTools = pkgs.gitAndTools }`

returns

    {
      hello = «derivation»;
      "gitAndTools/git" = «derivation»;
      "gitAndTools/hub" = «derivation»;
    }

`mkApp` is a helper function to construct `nix app`.

here is an example

``` nix
{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree {
          hello = pkgs.hello;
          gitAndTools = pkgs.gitAndTools;
        };
        defaultPackage = packages.hello;
        apps.hello = flake-utils.lib.mkApp { drv = packages.hello; };
        defaultApp = apps.hello;
      });
}
```

# Case Study 1: nix-tree

[utdemir](https://github.com/utdemir) has this nice and concise
[example](https://github.com/utdemir/nix-tree/blob/main/flake.nix) using
Flakes with a Haskell project. I think it is a great starting point to
understand Flakes.

in `nix-tree`, the outputs looks likes

``` nix
{
  outputs = { self, nixpkgs, flake-utils }: # list out the dependencies
    let
      overlay = self: super: { # a pattern of bring build artifacts to pkgs
        haskellPackages = super.haskellPackages.override {
          overrides = hself: hsuper: {
            nix-tree = hself.callCabal2nix "nix-tree"
              (self.nix-gitignore.gitignoreSourcePure [
                ./.gitignore
                "asciicast.sh"
                "flake.nix"
              ] ./.) { };
          };
        };
        nix-tree =
          self.haskell.lib.justStaticExecutables self.haskellPackages.nix-tree;
      };
    in {
      inherit overlay;
    } // flake-utils.lib.eachDefaultSystem (system: # leverage flake-utils
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        defaultPackage = pkgs.nix-tree;
        devShell = pkgs.haskellPackages.shellFor { # development environment
          packages = p: [ p."nix-tree" ];
          buildInputs = with pkgs.haskellPackages; [
            cabal-install
            ghcid
            ormolu
            hlint
            pkgs.nixpkgs-fmt
          ];
          withHoogle = false;
        };
      });
}
```

Let's break down the function a little bit. The outputs have 2
dependencies `nixpkgs` and `flake-utils`.

First thing, it construct an overlay contains the local `nix-tree` as
Haskell package and a derivation for the executable.

Next, for `eachDefaultSystem`, it initialize the new nixpkgs with
relevant system and overlay, and construct `defaultPackage` and
`devShell`. `devShell` is Nix Flakes' version of `nix-shell` (without -p
capability, if you want to use nix-shell -p, there is `nix shell`). We
can start a development shell by `nix develop` command. There is
`nix develop`
[integration](https://zimbatm.com/NixFlakes/#direnv-integration) with
`direnv`

# How to use non-flake dependency

Let's say if I want to use
[easy-purescript-nix](https://github.com/justinwoo/easy-purescript-nix)
in my project. First I need to add it as inputs

``` nix
{
  inputs.easy-ps = {
    url = "github:justinwoo/easy-purescript-nix/master";
    flake = false;
  };
}
```

there are more than one packages in `easy-purescript-nix`. I can added
them into an overlay and add the overlay into the `pkgs`.

``` nix
{
  outputs = {self, nixpkgs, easy-ps}: {
   overlay = final: prev: {

        purs = (prev.callPackage easy-ps {}).purs;
        spago = (prev.callPackage easy-ps {}).spago;
} // (
  flake-utils.lib.eachDefaultSystem  (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
        in rec {
            devShell = {
            packages =  [
              pkgs.purs
              pkgs.spago
            ];
          };
        };
   ));
```

On the another hand, you can use
[flake-compat](https://github.com/edolstra/flake-compat) to use Flakes
project from mainline (legacy) Nix.

# Case Study 2: [todomvc-nix](https://github.com/nix-community/todomvc-nix)

todomvc-nix is a much more complex example. It needs to build Haskell
(even ghcjs, which usually is more chanlleing to build) and rust source
code.

You can checkout the code yourself to see how one can override different
haskell packages and using
[numtide/devshell](https://github.com/numtide/devshell) to customize the
`nix develop` experience.

# [numtide/devshell](https://github.com/numtide/devshell)

devshell (not to confuse with Nix Flakes devShell) is numtide project to
customize per-project developer environments. The marketing slogan is
"like virtualenv, but for all the languages".

I think it is fair to say that devshel is still early stage of
development. (Although one can argue almost every thing mentioned in
this article is in the early stage of development.) Lots of usages are
subject to future changes. Using devshell probably requires you to read
throught the source code. But I think devshell is a really exicting
project.

## How to "install" devshell

devshell does aim to support non-Flakes and Flakes Nix. I am only going
to cover the Flakes version, the non-Flakes usage is covered at the
devshell's
[doc](https://numtide.github.io/devshell/getting_started.html).

First thing is to declare devshell as an input, and we need to import
devshell overlay into our instance of nixpkgs.

    flake-utils.lib.eachSystem [ "x86_64-darwin" ] (system:
         let
           pkgs = import nixpkgs {
             inherit system;
             overlays = [ devshell.overlay overlay ];
           };

the overlay would bring `devshell` attribute into the pkgs. `devshell`
has functions like
[`mkShell`](https://github.com/numtide/devshell/blob/master/default.nix#L86)
and
[`fromTOML`](https://github.com/numtide/devshell/blob/master/default.nix#L74).
`fromTOML` allows us to configure the devshell using TOML file.

``` nix
{
  # assuming we import devshell.overlay
  # and there is devshell.toml file
  devShell = pkgs.devshell.fromTOML ./devshell.toml;
}
```

`mkShell` allows us to use Nix experssions.

``` nix
{ devShell = pkgs.devshell.mkShell { name = "blog-dev-shell"; }; }
```

Here is [My devshell
config](https://github.com/yuanw/blog/blob/4b610ac5f481a71e3dc36b3098484f7e412294ae/flake.nix#L48).
devshell document page has a list of [configuration
options](https://numtide.github.io/devshell/modules_schema.html).

## environments variables

This is kind of like `shellHook` in the old `mkShell` function. We can
define environment variables in our devshell.

TOML version looks like

``` toml
[[env]]
name = "GO111MODULE"
value = "on" 
```

Nix version looks little verbose

``` nix
{
  devshell = pkgs.devshell.mkShell {
    env = [{
      name = "NODE_ENV";
      value = "development";
    }];
  };
}
```

## packages

Of course, we can define packages for our devshell TOML version

``` toml
[devshell]
packages = [
  "go"
]
```

Nix counterpart is more flexible, imagine I have a custom
`haskellPackages` with lots of overlays, I can reference it in
`flake.nix` pretty easily.

``` nix
{
  devshell =
    pkgs.devshell.mkShell { packages = [ myHaskellEnv pkgs.nixpkgs-fmt ]; };
}
```

## commands

I think this is a cool feature in devshell. Using Nix expressions we can
define some common commands for your project.

``` nix
{
  devshell = pkgs.devshell.mkShell {
    commands = [
      {
        name = "cssWatch";
        category = "css";
        command =
          "ls tailwind/*.css | ${pkgs.entr}/bin/entr ${pkgs.yarn}/bin/yarn build";
      }
      {
        name = "siteClean";
        category = "static site";
        help = "clean static site files";
        command = "${pkgs.blog}/bin/blog clean";
      }
      {
        name = "yarn";
        category = "javascript";
        package = "yarn";
      }
    ];
  };
}
```

Everytime, you can enter devshell, all commands and a motd (message of
the day) will be displayed. the commands are grouped by their category.
`packages` won't show up in there.

``` shell
🔨 Welcome to blog-dev-shell

[css]

  cssWatch

[general commands]

  menu      - prints this menu

[javascript]

  node      - Event-driven I/O framework for the V8 JavaScript engine
  yarn      - Fast, reliable, and secure dependency management for javascript

[purescript]

  purs
  spago

[static site]

  siteClean - clean static site files
  siteWatch - Watch static site files

[utility]

  entr      - Run arbitrary commands when files change
```

## modules

Right now, all the build-in modules are in
[devshell/extra](https://github.com/numtide/devshell/tree/master/extra)
directory.

-   git hook
-   locale
-   c
-   go
-   rust

One can write custom module. For example, nixpkgs haskell-modules has a
nice
[shellFor](https://github.com/NixOS/nixpkgs/blob/196682b1755abab6adef36666cc045f5dbb63281/pkgs/development/haskell-modules/make-package-set.nix#L288)
function, we can turn it into a haskell module for devshell.
