{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

--------------------------------------------------------------------------------

import Data.Monoid (mappend)
import Hakyll
import Text.Pandoc.Options (WriterOptions (..))
import Text.Pandoc.Templates

-- https://stackoverflow.com/questions/39815375/creating-a-document-with-pandoc/39862759#39862759
withToc :: WriterOptions
withToc =  defaultHakyllWriterOptions
        { writerNumberSections = True,
          writerTableOfContents = True,
          writerTOCDepth = 2,
          writerTemplate = Just "\n<div class=\"toc\"><h2>Table of Contents</h2>\n$toc$\n</div>\n$body$"
        }

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration =
  FeedConfiguration
    { feedTitle = "Yuan Wang's blog",
      feedDescription = "Yuan Wang's blog feed",
      feedAuthorName = "Yuan Wang",
      feedAuthorEmail = "me@yuanwang.ca",
      feedRoot = "https://yuanwang.ca"
    }

main :: IO ()
main = do
  _main withToc

config :: Configuration
config =
  defaultConfiguration
    { destinationDirectory = "dist"
    , previewPort = 5000
    }

--------------------------------------------------------------------------------
_main :: WriterOptions -> IO ()
_main writeOptions =
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
    match "posts/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompilerWith defaultHakyllReaderOptions writeOptions
          >>= loadAndApplyTemplate "templates/post.html" postCtx
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate "templates/default.html" postCtx
          >>= relativizeUrls
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
