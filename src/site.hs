{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

--------------------------------------------------------------------------------

import Control.Monad ((<=<))
import Control.Monad.State (State, get, modify', runState)
import Data.Functor.Identity (runIdentity)
import Data.Kind (Type)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as T
import Hakyll (Compiler, Configuration (destinationDirectory, previewPort, providerDirectory), Context, FeedConfiguration (..), Item (..), Tags, applyAsTemplate, buildTags, compile, compressCssCompiler, constField, copyFileCompiler, create, dateField, defaultConfiguration, defaultContext, defaultHakyllWriterOptions, fromCapture, fromList, getResourceBody, hakyllWith, idRoute, listField, loadAll, loadAndApplyTemplate, makeItem, match, pandocCompiler, pandocCompilerWith, pandocCompilerWithTransform, recentFirst, relativizeUrls, renderAtom, route, saveSnapshot, setExtension, tagsField, tagsRules, templateBodyCompiler, writePandocWith, (.||.))
import Hakyll.Web.Pandoc (defaultHakyllReaderOptions)
import System.Environment (lookupEnv)
import Text.Pandoc.Definition (Block (..), Inline (..), Pandoc (..))
import Text.Pandoc.Options (
  WriterOptions,
  writerNumberSections,
  writerTOCDepth,
  writerTableOfContents,
  writerTemplate,
 )
import Text.Pandoc.Shared (tshow)
import Text.Pandoc.SideNoteHTML (usingSideNotesHTML)
import Text.Pandoc.Templates (
  Template,
  compileTemplate,
 )
import Text.Pandoc.Walk (walk, walkM)

--------------------------------------------------------------------------------

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration =
  FeedConfiguration
    { feedTitle = "Yuan Wang's blog"
    , feedDescription = "Yuan Wang's blog feed"
    , feedAuthorName = "Yuan Wang"
    , feedAuthorEmail = "blog@yuanwang.ca"
    , feedRoot = "https://yuanwang.ca"
    }

config :: Configuration
config =
  defaultConfiguration
    { destinationDirectory = "dist"
    , previewPort = 5000
    , providerDirectory = "content"
    }

-- | Adds writer options for Table of Content rendering.
withTableOfContents :: WriterOptions -> WriterOptions
withTableOfContents options =
  options
    { writerNumberSections = False
    , writerTableOfContents = True
    , writerTOCDepth = 2
    , writerTemplate = Just tocTemplate
    }

tocTemplate :: Template T.Text
tocTemplate =
  either error id . runIdentity . compileTemplate "" $
    T.unlines
      [ "<div id=\"toc\" class=\"hidden\"><div class=\"header\">Table of Contents</div>"
      , "$toc$"
      , "</div>"
      , "$body$"
      ]

myWriter :: WriterOptions
-- myWriter = withTableOfContents defaultHakyllWriterOptions
myWriter = defaultHakyllWriterOptions

myPandocCompiler :: Compiler (Item String)
myPandocCompiler =
  pandocCompilerWithTransform
    defaultHakyllReaderOptions
    myWriter
    (usingSideNotesHTML myWriter)

-- https://frasertweedale.github.io/blog-fp/posts/2020-12-10-hakyll-section-links.html
addSectionLinks :: Pandoc -> Pandoc
addSectionLinks = walk \case
  Header n attr@(idAttr, _, _) inlines ->
    let link = Link ("", ["floatleft", "sec-link"], []) [Str "§"] ("#" <> idAttr, "")
     in Header n attr (inlines <> [link])
  block -> block

--------------------------------------------------------------------------------
main :: IO ()
main = do
  includeDraft <- lookupEnv "PREVIEW"
  let previewMode = fromMaybe "FALSE" includeDraft == "TRUE"
      postsPattern =
        if previewMode
          then "posts/*.org" .||. "drafts/*.org" .||. "drafts/*.md" .||. "posts/*.md"
          else "posts/*.org" .||. "posts/*.md"
  hakyllWith config $ do
    match "images/*" $ do
      route idRoute
      compile copyFileCompiler
    match "js/*" $ do
      route idRoute
      compile copyFileCompiler
    match "css/*" $ do
      route idRoute
      compile compressCssCompiler
    match (fromList []) $ do
      route $ setExtension "html"
      compile $
        myPandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls
    tags <- buildTags postsPattern (fromCapture "tags/*.html")
    tagsRules tags $ \tag pat -> do
      let title = "Posts with \"" ++ tag ++ "\""
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll pat
        let ctx =
              constField "title" title
                `mappend` listField "posts" (postCtxWithTags tags) (return posts)
                `mappend` defaultContext
        makeItem ""
          >>= loadAndApplyTemplate "templates/tags.html" ctx
          >>= loadAndApplyTemplate "templates/default.html" ctx
          >>= relativizeUrls
    match postsPattern $ do
      route $ setExtension "html"
      compile $
        myPandocCompiler
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate "templates/post.html" (postCtxWithTags tags)
          >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
          >>= relativizeUrls
    create ["CNAME"] $ do
      route idRoute
      compile $ makeItem ("yuanwang.ca" :: String)
    create ["atom.xml"] $ do
      route idRoute
      compile $ do
        let feedCtx = postCtx
        posts <-
          fmap (take 10) . recentFirst
            =<< loadAll postsPattern
        renderAtom myFeedConfiguration feedCtx posts
    create ["archive.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll postsPattern
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
        posts <- recentFirst =<< loadAll postsPattern
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
  dateField "date" "%B %e, %Y" <> defaultContext

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags <> postCtx
