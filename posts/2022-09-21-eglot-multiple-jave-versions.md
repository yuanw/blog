---
title: setup java IDE with emacs and nix
date: 2024-06-13
draft: true
tags: 
  - emacs
---

# introduction 

setup multiple java runtime for jdlts and eglot.

one would assume this is easy. But i did have to find lots trial and error.

```
              eglot = {
                enable = false;
                config = ''
                  (setq eglot-autoshutdown t)
                  (add-to-list 'eglot-server-programs
                  '((java-mode java-ts-mode) .

                  ("jdtls-with-lombok"
                  :initializationOptions
                      (:settings
                            (:java
                             (:configuration
                             (:runtimes [(:name "JavaSE-17" :path "${pkgs.jdk17.home}")
                                         (:name "JavaSE-21" :path "${pkgs.jdk21.home}" :default t)
                                       ]))))
                    )
                    )
                  ((go-mode go-dot-mod-mode go-dot-work-mode go-ts-mode go-mod-ts-mode)
                  . ("${pkgs.gopls}/bin/gopls"))
                  )
                '';
              };
```


how to configure emacs in nix ?

rcyee nixer way 

plus side: integrate with nix module

down side 

# References
- [Emacs as code navigation tool (youtube)](https://www.youtube.com/watch?app=desktop&v=Ihfc8sWHUN8)
- [lsp-mode vs. lsp-bridge vs. lspce vs. eglot (reddit)](https://www.reddit.com/r/emacs/comments/1c0v28k/lspmode_vs_lspbridge_vs_lspce_vs_eglot/)
