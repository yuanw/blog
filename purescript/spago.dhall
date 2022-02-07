{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
    [ "console"
    , "effect"
    , "psci-support"
    , "prelude"
    , "refs"
    , "transformers"
    , "web-dom"
    , "web-events"
    , "web-html"
    ]
, packages = ./packages.dhall
, sources = ["src/**/*.purs" ]
}
