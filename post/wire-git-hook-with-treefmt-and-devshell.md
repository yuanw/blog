---
title: Integrate git hooks with treefmt and devshell
description: wire git hooks with numtide devshell
tags: 
   - nix
   - git-hook
   - devshell
date: 2021-10-19
dubDate: 'October 19, 2021'
modified: October 24, 2021
---
# Background

I was looking for a way to integrate
[pre-commit-hooks.nix](https://github.com/cachix/pre-commit-hooks.nix)
and [numtide/devshell](https://github.com/numtide/devshell/), I came
across this [github
issue](https://github.com/numtide/devshell/issues/19). It seems zimbatm
added `git.hooks` extra module to support git hook integration in
devshell. So I decide to give a try.

# Code

I am configuring my devshell using nix, rather than toml file.

I think for toml version, you should just do

`devshell.toml`

    imports = ["git/hooks"]
    git.hooks.enable = true
    git.hooks.pre-comment = "treefmt"

assuming you already added devshell overlay, we need to import git extra
module, and enable `git.hooks` and add script for the hook we want to
use. Here i am using
[numtide/treefmt.](https://github.com/numtide/treefmt)

``` nix
devShell = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.extraModulesDir + "/git/hooks.nix") ];
          git.hooks.enable = true;
          git.hooks.pre-commit.text = "${pkgs.treefmt}/bin/treefmt";
}
```

assuming you have a `treefmt.toml` in your project root directory, you
should be to ready to go
