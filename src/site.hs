{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Monad (forM, void)
import Data.Aeson.Types (Result (..))
import Data.Aeson.Types qualified as A
import Data.HashMap.Strict qualified as HM
import Data.List (nub, sortOn)
import Data.Ord qualified as Ord
import Data.Text (Text)
import Data.Text qualified as T
import Data.Time (UTCTime, defaultTimeLocale, formatTime, parseTimeM)
import Deriving.Aeson
import Deriving.Aeson.Stock (PrefixedSnake)
import Development.Shake (Action, Rules, (%>), (|%>), (~>))
import Development.Shake qualified as Shake
import Development.Shake.FilePath ((<.>), (</>))
import Development.Shake.FilePath qualified as Shake
import Text.Mustache qualified as Mus
import Text.Mustache.Compile qualified as Mus
import Text.Pandoc (Block (Plain), Meta (..), MetaValue (..), Pandoc (..))
import Text.Pandoc qualified as Pandoc

main :: IO ()
main = Shake.shakeArgs Shake.shakeOptions $ do
  Shake.withTargetDocs "Build the site" $
    "build" ~> buildTargets
  Shake.withTargetDocs "Clean the built site" $
    "clean" ~> Shake.removeFilesAfter outputDir ["//*"]

  Shake.withoutTargets buildRules

outputDir :: String
outputDir = "_site"

-- end snippet main

-- start snippet build-targets
buildTargets :: Action ()
buildTargets = do
  assetPaths <- Shake.getDirectoryFiles "" assetGlobs
  Shake.need $ map (outputDir </>) assetPaths

  -- Shake.need $ map indexHtmlOutputPath pagePaths

  postPaths <- Shake.getDirectoryFiles "" postGlobs
  Shake.need $ map indexHtmlOutputPath postPaths

  Shake.need $ map (outputDir </>) ["archive/index.html", "index.html"]

  posts <- forM postPaths readPost
  Shake.need
    [ outputDir </> "tags" </> T.unpack tag </> "index.html"
    | post <- posts
    , tag <- postTags post
    ]

-- end snippet build-targets

-- start snippet paths
assetGlobs :: [String]
assetGlobs = ["css/*.css", "images/*.png"]

pagePaths :: [String]
pagePaths = ["about.md", "contact.md"]

postGlobs :: [String]
postGlobs = ["posts/*.md"]

indexHtmlOutputPath :: FilePath -> FilePath
indexHtmlOutputPath srcPath =
  outputDir </> Shake.dropExtension srcPath </> "index.html"

-- end snippet paths

-- start snippet build-targets-parallel
buildTargetsParallel :: Action ()
buildTargetsParallel = do
  (assetPaths, postPaths) <-
    Shake.getDirectoryFiles "" assetGlobs
      `Shake.par` Shake.getDirectoryFiles "" postGlobs
  posts <- Shake.forP postPaths readPost

  void $
    Shake.parallel
      [ Shake.need $
          map
            (outputDir </>)
            ( assetPaths
                <> ["archive/index.html", "index.html"]
                <> [ "tags" </> T.unpack tag </> "index.html"
                   | post <- posts
                   , tag <- postTags post
                   ]
            )
      , Shake.need $ map indexHtmlOutputPath (pagePaths <> postPaths)
      ]

-- end snippet build-targets-parallel

-- start snippet build-rules
buildRules :: Rules ()
buildRules = do
  assets
  pages
  posts
  archive
  tags
  home

-- end snippet build-rules

-- start snippet assets
assets :: Rules ()
assets =
  map (outputDir </>) assetGlobs |%> \target -> do
    let src = Shake.dropDirectory1 target
    Shake.copyFileChanged src target
    Shake.putInfo $ "Copied " <> target <> " from " <> src

-- end snippet assets

-- start snippet pages-1
data Page = Page {pageTitle :: Text, pageContent :: Text}
  deriving (Show, Generic)
  deriving (ToJSON) via PrefixedSnake "page" Page

-- end snippet pages-1

-- start snippet pages-2
pages :: Rules ()
pages =
  map indexHtmlOutputPath pagePaths |%> \target -> do
    let src = indexHtmlSourcePath target
    (meta, html) <- markdownToHtml src

    let page = Page (meta HM.! ("title" :: String)) html
    applyTemplateAndWrite "default.html" page target
    Shake.putInfo $ "Built " <> target <> " from " <> src

indexHtmlSourcePath :: FilePath -> FilePath
indexHtmlSourcePath =
  Shake.dropDirectory1
    . (<.> "md")
    . Shake.dropTrailingPathSeparator
    . Shake.dropFileName

-- end snippet pages-2

-- start snippet posts-1
data Post = Post
  { postTitle :: Text
  , postAuthor :: Maybe Text
  , postTags :: [Text]
  , postDate :: Maybe Text
  , postContent :: Maybe Text
  , postLink :: Maybe Text
  }
  deriving (Show, Generic)
  deriving (FromJSON, ToJSON) via PrefixedSnake "post" Post

-- end snippet posts-1

-- start snippet posts-2
posts :: Rules ()
posts =
  map indexHtmlOutputPath postGlobs |%> \target -> do
    let src = indexHtmlSourcePath target
    post <- readPost src
    postHtml <- applyTemplate "post.html" post

    let page = Page (postTitle post) postHtml
    applyTemplateAndWrite "default.html" page target
    Shake.putInfo $ "Built " <> target <> " from " <> src

readPost :: FilePath -> Action Post
readPost postPath = do
  date <-
    parseTimeM False defaultTimeLocale "%Y-%-m-%-d"
      . take 10
      . Shake.takeBaseName
      $ postPath
  let formattedDate =
        T.pack $ formatTime @UTCTime defaultTimeLocale "%b %e, %Y" date

  (post, html) <- markdownToHtml postPath
  Shake.putInfo $ "Read " <> postPath
  return $
    post
      { postDate = Just formattedDate
      , postContent = Just html
      , postLink = Just . T.pack $ "/" <> Shake.dropExtension postPath <> "/"
      }

-- end snippet posts-2

-- start snippet archive
archive :: Rules ()
archive =
  outputDir </> "archive/index.html" %> \target -> do
    postPaths <- Shake.getDirectoryFiles "" postGlobs
    posts <- sortOn (Ord.Down . postDate) <$> forM postPaths readPost
    writeArchive (T.pack "Archive") posts target

writeArchive :: Text -> [Post] -> FilePath -> Action ()
writeArchive title posts target = do
  html <- applyTemplate "archive.html" $ HM.singleton ("posts" :: String) posts
  applyTemplateAndWrite "default.html" (Page title html) target
  Shake.putInfo $ "Built " <> target

-- end snippet archive

-- start snippet tags
tags :: Rules ()
tags =
  outputDir </> "tags/*/index.html" %> \target -> do
    let tag = T.pack $ Shake.splitDirectories target !! 2
    postPaths <- Shake.getDirectoryFiles "" postGlobs
    posts <-
      sortOn (Ord.Down . postDate)
        . filter ((tag `elem`) . postTags)
        <$> forM postPaths readPost
    writeArchive (T.pack "Posts tagged " <> tag) posts target

-- end snippet tags

-- start snippet home
home :: Rules ()
home =
  outputDir </> "index.html" %> \target -> do
    postPaths <- Shake.getDirectoryFiles "" postGlobs
    posts <-
      take 3
        . sortOn (Ord.Down . postDate)
        <$> forM postPaths readPost
    html <- applyTemplate "home.html" $ HM.singleton ("posts" :: String) posts

    let page = Page (T.pack "Home") html
    applyTemplateAndWrite "default.html" page target
    Shake.putInfo $ "Built " <> target

-- end snippet home

-- start snippet pandoc
markdownToHtml :: (FromJSON a) => FilePath -> Action (a, Text)
markdownToHtml filePath = do
  content <- Shake.readFile' filePath
  Shake.quietly . Shake.traced "Markdown to HTML" $ do
    pandoc@(Pandoc meta _) <-
      runPandoc . Pandoc.readMarkdown readerOptions . T.pack $ content
    meta' <- fromMeta meta
    html <- runPandoc . Pandoc.writeHtml5String writerOptions $ pandoc
    return (meta', html)
  where
    readerOptions =
      Pandoc.def {Pandoc.readerExtensions = Pandoc.pandocExtensions}
    writerOptions =
      Pandoc.def {Pandoc.writerExtensions = Pandoc.pandocExtensions}

    fromMeta (Meta meta) =
      traverse metaValueToJSON meta
        >>= ( \case
                Success res -> pure res
                Error err -> fail $ "json conversion error:" <> err
            )
          . A.fromJSON
          . A.toJSON

    metaValueToJSON = \case
      MetaMap m -> A.toJSON <$> traverse metaValueToJSON m
      MetaList m -> A.toJSONList <$> traverse metaValueToJSON m
      MetaBool m -> pure $ A.toJSON m
      MetaString m -> pure $ A.toJSON $ T.strip m
      MetaInlines m -> metaValueToJSON $ MetaBlocks [Plain m]
      MetaBlocks m ->
        fmap (A.toJSON . T.strip)
          . runPandoc
          . Pandoc.writePlain Pandoc.def
          $ Pandoc mempty m

    runPandoc action =
      Pandoc.runIO (Pandoc.setVerbosity Pandoc.ERROR >> action)
        >>= either (fail . show) return

-- end snippet pandoc

-- start snippet mustache
applyTemplate :: (ToJSON a) => String -> a -> Action Text
applyTemplate templateName context = do
  tmpl <- readTemplate $ "templates" </> templateName
  case Mus.checkedSubstitute tmpl (A.toJSON context) of
    ([], text) -> return text
    (errs, _) ->
      fail $
        "Error while substituting template "
          <> templateName
          <> ": "
          <> unlines (map show errs)

applyTemplateAndWrite :: (ToJSON a) => String -> a -> FilePath -> Action ()
applyTemplateAndWrite templateName context outputPath =
  applyTemplate templateName context
    >>= Shake.writeFile' outputPath . T.unpack

readTemplate :: FilePath -> Action Mus.Template
readTemplate templatePath = do
  Shake.need [templatePath]
  eTemplate <-
    Shake.quietly
      . Shake.traced "Compile template"
      $ Mus.localAutomaticCompile templatePath
  case eTemplate of
    Right template -> do
      Shake.need . Mus.getPartials . Mus.ast $ template
      Shake.putInfo $ "Read " <> templatePath
      return template
    Left err -> fail $ show err
