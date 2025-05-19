---
title: Using Tmux with Nix
date: 2021-10-19
pubDate: 'October 19, 2021'
modified: 'October 24, 2021'
description: How I configure tmux with nix
tags: 
  - tmux
  - nix
  - home-manager
---

# TL;DR

I throw all my tmux configuration (along with some basic alacritty and
starship configuration) into a [nix
module](https://github.com/yuanw/nix-home/blob/master/modules/terminal/default.nix).
I really enjoy using it so far. I hope it can give you some ideas about
how to potentially improve your workflow

# Longer version

Before using Nix, I had very limited experience with Tmux. I think I
only used once when I ssh into some ec2 box for doing mutlipy long
running jobs. After adpating Nix, I started to try out Alacirtty (I was
having a hard time to get Kitty build on MacOS with Nix), I really like
Alacirtty, but it doesn't support tabs or split, the community
recommends using window manager or terminal multiplexer. The idea didn't
bother me too much. (I brought a [tmux
2](https://pragprog.com/titles/bhtmux2/tmux-2/) book long before that,
never read it), I thought to myself: maybe this is a good oppurity to
learn tmux. So I skip through the book, and set up tmux with basic
configuration using nix home manager, and back to everyday work. I
didn't leverage tmux too much, and I often feel like I should spend some
more time to tweak my configuration, so it suits my use case better. One
day I came across [waylonwalker's
blog](https://waylonwalker.com/tmux-nav-2021/), which introduce Chirs
Toomy's thoughtbot course on tmux to me. These materials really give me
lots of ideas, and after some embarrassing long hours, I finally manage
to put all my tmux configuration into a single nix module.

Here are some lessons and tricks I learned:

# `display-popup` and `display-menu`

Most of tmux material I came cross are little bit of dated. The latest
version of tmux at the moment of writing is 3.2a. I think "new" (I am
not sure how new are they) commands like `display-popup` and
`display-menu` are really cool. If you are using tmux, and not aware of
them, I think you should give them a try. They might helps you to
improve your workflow. waylonwalker's blog has some cool ideas on how to
use `display-popup`. There is an example how I use `display-menu` and
`display-popup`

Basically `diplay-menu` allow you to display a menu on a specific
position with a title. You choose items from Menu using arrow keys or
shortcut, usually item is tmux command. You can optionally add an visual
divider between items.

    bind-key Tab display-menu -T "#[align=centre]Sessions" "Switch" . 'choose-session -Zw' Last l "switch-client -l" ${tmuxMenuSeperator} \
                  "Open Main Workspace" m "display-popup -E \" td ${cfg.mainWorkspaceDir} \"" "Open Sec Workspace" s "display-popup -E \" td ${cfg.secondaryWorkspaceDir} \""   ${tmuxMenuSeperator} \
                  "Kill Current Session" k "run-shell 'tmux switch-client -n \; tmux kill-session -t #{session_name}'"  "Kill Other Sessions" o "display-popup -E \"tkill \"" ${tmuxMenuSeperator} \
                  Random r "run-shell 'tat random'" Emacs e "run-shell 'temacs'" ${tmuxMenuSeperator} \
                  Exit q detach"

![](../../../assets/tmux-menu.png)

# Have a visual cue on tmux prefix press

You might want to hit whether you currently press tmux prefix key or
not. I found this nice
[solution](https://stackoverflow.com/questions/12003726/give-a-hint-when-press-prefix-key-in-tmux)

Without press prefix ![](../../../assets/tmux-prefix-before.png)

with prefix press ![](../../../assets/tmux-prefix-after.png)

# Mouse or no mouse

Maybe you think the point of tmux is to do mouse-free workflow, to
enable mouse in tmux might seems wrong. But there are certain tasks like
resizing panel are easier with Mouse. You can even set a command to
toggle enabling mouse.

# Use oh-my-zsh tmux plugin to start tmux automatically

I am using `zsh` and `oh-my-zsh`, it has a
[tmux](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/tmux/tmux.plugin.zsh)
plugin.

# A single nix module

Nix module allows us to group all tmux related configurations (bash
script, zsh and tmux) into a single place.
