{-# LANGUAGE OverloadedStrings #-}

--------------------------------------------------------------------------------
import Data.Functor.Identity (runIdentity)
import qualified Data.Text                     as T
import Hakyll
  ( Configuration (destinationDirectory, previewPort, providerDirectory),
    Context,
    FeedConfiguration (..),
    Tags,
    applyAsTemplate,
    buildTags,
    compile,
    compressCssCompiler,
    constField,
    copyFileCompiler,
    create,
    dateField,
    defaultConfiguration,
    defaultContext,
    fromCapture,
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
    pandocCompilerWith,
    recentFirst,
    relativizeUrls,
    renderAtom,
    route,
    saveSnapshot,
    setExtension,
    tagsField,
    tagsRules,
    templateBodyCompiler,
    (.||.),
  )
import System.Environment (getArgs)
import           Text.Pandoc.Options            ( WriterOptions
                                                , writerNumberSections
                                                , writerTOCDepth
                                                , writerTableOfContents
                                                , writerTemplate
                                                ) 
import           Text.Pandoc.Templates          ( Template
                                                , compileTemplate
                                                )
import Hakyll.Web.Pandoc (defaultHakyllReaderOptions)
import Hakyll (defaultHakyllWriterOptions)

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
      previewPort = 5000,
      providerDirectory = "content"
    }


-- | Adds writer options for Table of Content rendering.
withTableOfContents :: WriterOptions -> WriterOptions
withTableOfContents options = options { writerNumberSections  = False
                                      , writerTableOfContents = True
                                      , writerTOCDepth        = 2
                                      , writerTemplate        = Just tocTemplate
                                      }

tocTemplate :: Template T.Text
tocTemplate =
  either error id . runIdentity . compileTemplate "" $
    T.unlines
      [ "<div id=\"toc\" class=\"hidden\"><div class=\"header\">Table of Contents</div>",
        "$toc$",
        "</div>",
        "$body$"
      ]

--------------------------------------------------------------------------------
main :: IO ()
main = do
  (action : _) <- getArgs
  let previewMode = action == "watch"
      postsPattern =
        if previewMode
          then "posts/*.org" .||. "drafts/*.org" .||. "posts/*.md"
          else "posts/*.org"
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
        pandocCompiler
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
        pandocCompilerWith defaultHakyllReaderOptions (withTableOfContents defaultHakyllWriterOptions )
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
