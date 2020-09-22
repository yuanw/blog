{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

--------------------------------------------------------------------------------

import Data.Monoid (mappend)
import Hakyll
  ( Configuration (destinationDirectory, previewPort, providerDirectory),
    Context,
    FeedConfiguration (..),
    applyAsTemplate,
    compile,
    compressCssCompiler,
    constField,
    copyFileCompiler,
    create,
    dateField,
    defaultConfiguration,
    defaultContext,
    fromList,
    getResourceBody,
    hakyllWith,
    idRoute,
    listField,
    loadAll,
    loadAndApplyTemplate,
    makeItem,
    match,
    pandocCompiler,
    recentFirst,
    relativizeUrls,
    renderAtom,
    route,
    saveSnapshot,
    setExtension,
    templateBodyCompiler,
  )

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration =
  FeedConfiguration
    { feedTitle = "Yuan Wang's blog",
      feedDescription = "Yuan Wang's blog feed",
      feedAuthorName = "Yuan Wang",
      feedAuthorEmail = "me@yuanwang.ca",
      feedRoot = "https://yuanwang.ca"
    }

config :: Configuration
config =
  defaultConfiguration
    { destinationDirectory = "dist",
      previewPort = 7000,
      providerDirectory = "content"
    }

--------------------------------------------------------------------------------
main :: IO ()
main =
  hakyllWith config $ do
    match "images/*" $ do
      route idRoute
      compile copyFileCompiler
    match "css/*" $ do
      route idRoute
      compile compressCssCompiler
    match (fromList ["about.org"]) $ do
      route $ setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls
    match "posts/*.org" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate "templates/post.html" postCtx
          >>= loadAndApplyTemplate "templates/default.html" postCtx
          >>= relativizeUrls
    create ["CNAME"] $ do
      route idRoute
      compile $ makeItem @String "yuanwang.ca"
    create ["atom.xml"] $ do
      route idRoute
      compile $ do
        let feedCtx = postCtx
        posts <-
          fmap (take 10) . recentFirst
            =<< loadAll "posts/*"
        renderAtom myFeedConfiguration feedCtx posts
    create ["archive.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let archiveCtx =
              listField "posts" postCtx (return posts)
                `mappend` constField "title" "Archives"
                `mappend` defaultContext
        makeItem ""
          >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
          >>= loadAndApplyTemplate "templates/default.html" archiveCtx
          >>= relativizeUrls
    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let indexCtx =
              listField "posts" postCtx (return posts)
                `mappend` constField "title" "Home"
                `mappend` defaultContext
        getResourceBody
          >>= applyAsTemplate indexCtx
          >>= loadAndApplyTemplate "templates/default.html" indexCtx
          >>= relativizeUrls
    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y"
    `mappend` defaultContext
