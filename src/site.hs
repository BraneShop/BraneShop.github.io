--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

import           Data.List (isPrefixOf, tails, findIndex, intercalate, sortBy)
import           Data.Maybe (fromMaybe)
import           Control.Applicative (Alternative (..))
import           Data.Monoid ((<>), mconcat)
import           Hakyll
import           Control.Applicative
import qualified Data.Set as S
import qualified Data.Map as M
import           Text.Pandoc.Options
import           Control.Monad
import           Hakyll.Web.Diagrams (pandocCompilerDiagrams)
import           Data.Time.Clock (UTCTime)
import           System.FilePath (takeFileName)
import           Data.Time.Format (parseTimeM)
import           Data.Time.Format (defaultTimeLocale)
import           Data.Time.Clock (UTCTime)


--
-- Only available in Hakyll 4.5.*
-- import           Hakyll.Web.Feed     (renderAtomWithTemplates)
--------------------------------------------------------------------------------


pandocMathCompiler =
    let mathExtensions = [Ext_tex_math_dollars, Ext_latex_macros,
                         Ext_backtick_code_blocks]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions = foldr S.insert defaultExtensions mathExtensions
        writerOptions = defaultHakyllWriterOptions {
                          writerExtensions = newExtensions,
                          writerHTMLMathMethod = MathJax ""
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions


main :: IO ()
main = hakyll $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler

    match "files/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "data/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/**" $ do
        route   idRoute
        compile compressCssCompiler

    -- Load the upcoming workshops for consideration.
    match "workshops/**" $ do
        route idRoute
        compile $ getResourceBody
                    >>= applyAsTemplate (defaultContext <> listContext "|" "dates")

    match "videos/**" $ do
        route idRoute
        compile $ getResourceBody

    match "showreel/*" $ do
        tags <- buildTags "showreel/*" (fromCapture "showreel-tags/*.html")

        let ctx = braneContext
                    <> tagsField "tags" tags
                    <> constField "imageDescription" "Braneshop Showreel"
                    <> field "nextPost" (nextPostUrl "showreel/*")
                    <> field "nextPostTitle" (nextPostTitle "showreel/*")
                    <> field "prevPost" (previousPostUrl "showreel/*")
                    <> field "prevPostTitle" (previousPostTitle "showreel/*")

        tagsRules tags $ \tag pattern -> do
            let title = "Items tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll pattern
                tagCloud <- renderTagCloud 90 180 tags
                let ctx' = constField "title" title
                          <> listField "posts" postCtx (return posts)
                          <> constField "class" "compressed"
                          <> braneContext
                          <> constField "tagCloud" tagCloud
                          <> constField "showreel" "showreel"

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx'
                    >>= loadAndApplyTemplate "templates/default.html" ctx'
                    >>= relativizeUrls

        route $ setExtension "html"
        compile $ 
                (pandocMathCompiler)
            >>= applyAsTemplate ctx
            >>= loadAndApplyTemplate "templates/showreel-item.html" ctx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/showreel-display.html" ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx
            >>= relativizeUrls


    match "posts/*" $ do
        tags <- buildTags "posts/*" (fromCapture "tags/*.html")

        tagsRules tags $ \tag pattern -> do
            let title = "Posts tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll pattern
                tagCloud <- renderTagCloud 90 180 tags
                let ctx = constField "title" title
                          <> listField "posts" postCtx (return posts)
                          <> constField "class" "compressed"
                          <> braneContext
                          <> constField "tagCloud" tagCloud

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls


        route $ setExtension "html"
        compile $ 
                pandocMathCompiler
            >>= loadAndApplyTemplate "templates/post-with-video-and-image.html" (postCtxWithTags tags)
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls


    create ["6-week-workshop-on-deep-learning.html"] $ do
      route idRoute
      compile $ makeItem $ Redirect "technical-deep-learning-workshop.html"


    create ["deep-learning-workshop.html"] $ do
      route idRoute
      compile $ makeItem $ Redirect "ai-for-leadership.html"


    create ["manifold/index.html"] $ do
      route idRoute
      let ctx = braneContext
      compile $ do
          getResourceBody
              >>= applyAsTemplate ctx
              -- >>= loadAndApplyTemplate "templates/manifold.html" ctx
              >>= relativizeUrls

    match (fromList [ "custom-ai-workshop.html"
                    , "team.html"
                    , "quickstart.html"
                    , "faq.html"
                    , "pathway.html"
                    , "privacy.html"
                    , "contact.html"
                    , "events.html"
                    , "workshops.html"
                    , "thesetestimonialsdontexist.html"
                    , "object-detection-in-the-browser.html"
                    ]) $ do
        route idRoute

        compile $ do
            let ctx = braneContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match "about.html" $ do
        route idRoute
        compile $ do
            -- Hack: We take it as a list, so we can for-loop over it and
            -- extract out fields. But we'll only ever have one.
            let ctx = braneContext
                        <> listField "videos" braneContext (recentFirst =<< loadAll "videos/**")

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
                    


    match "ai-for-leadership.html" $ do
        route idRoute
        compile $ do
            -- Hack: We take it as a list, so we can for-loop over it and
            -- extract out fields. But we'll only ever have one.
            firstWorkshop <- fmap (take 1) . chronological =<< loadAll "workshops/leadership/*"
            let ctx = braneContext
                        <> listField "aflWorkshops" workshopContext (chronological =<< loadAll "workshops/leadership/**")
                        <> listField "firstWorkshop" workshopContext (return firstWorkshop)
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
                    

    match "technical-deep-learning-workshop.html" $ do
        route idRoute
        compile $ do
            firstWorkshop <- fmap (take 1) . chronological =<< loadAll "workshops/tdl/*"
            let ctx = braneContext
                        <> listField "techWorkshops" workshopContext (chronological =<< loadAll "workshops/tdl/**")
                        <> listField "firstWorkshop" workshopContext (return firstWorkshop)
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match (fromList ["showreel.html"]) $ do
        route idRoute
        compile $ do
            tags  <- buildTags "showreel/*" (fromCapture "showreel-tags/*.html")
            posts <- recentFirst =<<
                      loadAllSnapshots "showreel/*" "content"

            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    <> postCtx
                    <> bodyField "content"

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match (fromList ["blog.html"]) $ do
        route idRoute
        compile $ do
            -- No limit; show all the posts.
            tags  <- buildTags "posts/*" (fromCapture "tags/*.html")
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    <> braneContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 4) . recentFirst =<< loadAll "posts/*"
            tags  <- buildTags "posts/*" (fromCapture "tags/*.html")

            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    <> braneContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
                >>= minifyHTML


    match "templates/**" $ compile templateCompiler

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx <> teaserField "description" "content"
            posts <- fmap (take 10) . recentFirst =<<
                loadAllSnapshots "posts/*" "content"
            renderAtom feedConf feedCtx posts

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx <> teaserField "description" "content"
            posts <- fmap (take 10) . recentFirst =<<
                loadAllSnapshots "posts/*" "content"
            renderRss feedConf feedCtx posts


feedConf :: FeedConfiguration
feedConf = FeedConfiguration
    { feedTitle         = "Braneshop | braneshop.com.au"
    , feedDescription   = "The blog of the Braneshop team."
    , feedAuthorName    = "Braneshop Team"
    , feedAuthorEmail   = "hello@braneshop.com.au"
    , feedRoot          = "https://braneshop.com.au"
    }


previousPostUrl :: Pattern -> Item String -> Compiler String
previousPostUrl path post = do
    sortedPosts <- sortChronological =<< getMatches path
    let ident = itemIdentifier post
        ident' = itemBefore sortedPosts ident
    case ident' of
        Just i -> (fmap (maybe empty toUrl) . getRoute) i
        Nothing -> empty

previousPostTitle :: Pattern -> Item String -> Compiler String
previousPostTitle path post = do
    sortedPosts <- sortChronological =<< getMatches path
    let ident = itemIdentifier post
        ident' = itemBefore sortedPosts ident
    case ident' of
        Just i -> fmap (maybe empty id) (getMetadataField i "title")
        Nothing -> empty

nextPostTitle :: Pattern -> Item String -> Compiler String
nextPostTitle path post = do
    sortedPosts <- sortChronological =<< getMatches path
    let ident = itemIdentifier post
        ident' = itemAfter sortedPosts ident
    case ident' of
        Just i -> fmap (maybe empty id) (getMetadataField i "title")
        Nothing -> empty

nextPostUrl :: Pattern -> Item String -> Compiler String
nextPostUrl path post = do
    sortedPosts <- sortChronological =<< getMatches path
    let ident = itemIdentifier post
        ident' = itemAfter sortedPosts ident
    case ident' of
        Just i -> fmap (maybe empty toUrl) (getRoute i)
        Nothing -> empty

sortIdentifiersByDate :: [Identifier] -> [Identifier]
sortIdentifiersByDate identifiers =
    reverse $ sortBy byDate identifiers
        where
            byDate id1 id2 =
                let fn1 = takeFileName $ toFilePath id1
                    fn2 = takeFileName $ toFilePath id2
                    parseTime' fn = parseTimeM True defaultTimeLocale "%Y-%m-%d" $ intercalate "-" $ take 3 $ splitAll "-" fn
                in compare ((parseTime' fn1) :: Maybe UTCTime) ((parseTime' fn2) :: Maybe UTCTime)

itemAfter :: Eq a => [a] -> a -> Maybe a
itemAfter xs x =
    lookup x $ zip xs (tail xs)


itemBefore :: Eq a => [a] -> a -> Maybe a
itemBefore xs x =
    lookup x $ zip (tail xs) xs


urlOfPost :: Item String -> Compiler String
urlOfPost =
    fmap (maybe empty $ toUrl) . getRoute . itemIdentifier


--------------------------------------------------------------------------------
-- buildTagsWith' :: MonadMetadata m
--               => (Identifier -> m [String])
--               -> Pattern
--               -> (String -> Identifier)
--               -> m Tags
-- buildTagsWith' f pattern makeId = do
--     ids    <- getMatches pattern
--     tagMap <- foldM addTags M.empty ids
--     let set' = S.fromList ids
--     return $ Tags (M.toList tagMap) makeId (PatternDependency pattern set')
--   where
--     -- Create a tag map for one page
--     addTags tagMap id' = do
--         tags <- f id'
--         let tagMap' = M.fromList $ zip tags $ repeat [id']
--         return $ M.unionWith (++) tagMap tagMap'


-- customRenderAtom :: FeedConfiguration -> Context String -> [Item String] -> Compiler (Item String)
-- customRenderAtom config context items = do
--   atomTemplate     <- unsafeCompiler $ readFile "templates/atom.xml"
--   atomItemTemplate <- unsafeCompiler $ readFile "templates/atom-item.xml"
--   renderAtomWithTemplates atomTemplate atomItemTemplate config context items


postCtx :: Context String
postCtx = 
       teaserField "teaser" "content"
    <> field "nextPost" (nextPostUrl "posts/*")
    <> field "nextPostTitle" (nextPostTitle "posts/*")
    <> field "prevPost" (previousPostUrl "posts/*")
    <> field "prevPostTitle" (previousPostTitle "posts/*")
    <> braneContext


workshopContext :: Context String
workshopContext 
  = dateField "date" "%B %e, %Y"
  <> listFieldWith "dates" defaultContext (\i -> do 
      let identifier = itemIdentifier i 
      metadata <- getMetadata identifier
      let metas = maybe [] (map trim . splitAll "\\|") $ lookupString "dates" metadata
      return $ map (\x -> Item (fromFilePath x) x) metas
    )
  <> defaultContext


braneContext :: Context String
braneContext = 
  constField "rootUrl" "https://braneshop.com.au"
  <> constField "class" "compressed"
  <> dateField "date" "%B %e, %Y"
  <> listField "workshops" workshopContext (chronological =<< loadAll "workshops/**")
  <> listContext "," "classes" -- Converts this field into a proper list.
  <> defaultContext


postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags
                       <> postCtx

listContextWith :: String -> Context String -> String -> Context a
listContextWith token ctx s = listField s ctx $ do
    identifier <- getUnderlying
    metadata   <- getMetadata identifier
    let metas = maybe [] (map trim . splitAll token) $ lookupString s metadata
    return $ map (\x -> Item (fromFilePath x) x) metas


listContext :: String -> String -> Context a
listContext token = listContextWith token defaultContext


minifyHTML :: Item String -> Compiler (Item String)
minifyHTML = withItemBody $ unixFilter "tidy" (tidyOptionsHTML ++ tidyOptionsMinify)


tidyOptionsDefault =
    [ "-q"
    , "--output-encoding utf8"
    , "--tidy-mark no"
    , "--mute-id yes"
    , "--wrap 0"
    ]

tidyOptionsHTML =
    tidyOptionsDefault ++
    [ "--output-html yes"
    , "--logical-emphasis yes"
    , "--warn-proprietary-attributes no"
    , "--priority-attributes id,class,name,property,rel,href"
    , "--sort-attributes alpha"
    , "--merge-divs no"
    , "--merge-spans no"
    , "--drop-empty-elements no"
    ]

tidyOptionsMinify =
    [ 
    "--vertical-space auto"
    ]
