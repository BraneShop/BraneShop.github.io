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
    match "images/**/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "files/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "data/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "events/*" $ do
        let ctx = defaultContext'

        route $ setExtension "html"

        compile $ 
                (pandocMathCompiler)
            >>= applyAsTemplate ctx
            >>= loadAndApplyTemplate "templates/event-item.html" ctx
            -- >>= loadAndApplyTemplate "templates/default.html" ctx
            >>= relativizeUrls

    match "showreel/*" $ do
        tags <- buildTags "showreel/*" (fromCapture "showreel-tags/*.html")

        let ctx = postCtxWithTags tags

        tagsRules tags $ \tag pattern -> do
            let title = "Items tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll pattern
                tagCloud <- renderTagCloud 90 180 tags
                let ctx' = constField "title" title
                          <> listField "posts" postCtx (return posts)
                          <> constField "class" "compressed"
                          <> defaultContext'
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
                          <> defaultContext'
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


    match (fromList ["deep-learning-workshop.html"
                    , "ai-for-leadership.html"
                    , "6-week-workshop-on-deep-learning.html"
                    , "team.html"
                    , "contact.html"
                    , "thesetestimonialsdontexist.html"
                    , "privacy.html"
                    , "quickstart.html"
                    , "faq.html"
                    , "community.html"
                    , "object-detection-in-the-browser.html"
                    ]) $ do
        route idRoute

        let ctx = listContext "classes"
                  <> defaultContext'

        compile $ do
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match (fromList ["events.html"]) $ do
        route idRoute
        compile $ do
            events <- recentFirst =<< loadAll "events/*"

            let ctx =
                    listField "events" defaultContext' (return events)
                    <> bodyField "content"
                    <> defaultContext'

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
                    <> defaultContext'

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match (fromList ["poster.html"]) $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= applyAsTemplate defaultContext'
                >>= loadAndApplyTemplate "templates/branded.html" defaultContext'
                >>= relativizeUrls


    match (fromList [ "index.html"
                    ]) $ do
        route idRoute
        compile $ do
            posts <- fmap (take 4) . recentFirst =<< loadAll "posts/*"
            tags <- buildTags "posts/*" (fromCapture "tags/*.html")

            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    <> defaultContext'

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext'
                >>= relativizeUrls


    match "templates/*" $ compile templateCompiler


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


previousPostUrl :: Item String -> Compiler String
previousPostUrl post = do
    sortedPosts <- sortChronological =<< getMatches "posts/*"
    let ident = itemIdentifier post
        ident' = itemBefore sortedPosts ident
    case ident' of
        Just i -> (fmap (maybe empty toUrl) . getRoute) i
        Nothing -> empty

previousPostTitle :: Item String -> Compiler String
previousPostTitle post = do
    sortedPosts <- sortChronological =<< getMatches "posts/*"
    let ident = itemIdentifier post
        ident' = itemBefore sortedPosts ident
    case ident' of
        Just i -> fmap (maybe empty id) (getMetadataField i "title")
        Nothing -> empty

nextPostTitle :: Item String -> Compiler String
nextPostTitle post = do
    sortedPosts <- sortChronological =<< getMatches "posts/*"
    let ident = itemIdentifier post
        ident' = itemAfter sortedPosts ident
    case ident' of
        Just i -> fmap (maybe empty id) (getMetadataField i "title")
        Nothing -> empty

nextPostUrl :: Item String -> Compiler String
nextPostUrl post = do
    sortedPosts <- sortChronological =<< getMatches "posts/*"
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
    <> field "nextPost" nextPostUrl
    <> field "nextPostTitle" nextPostTitle
    <> field "prevPost" previousPostUrl
    <> field "previousPostTitle" previousPostTitle
    <> defaultContext'


defaultContext' :: Context String
defaultContext' = 
  constField "rootUrl" "https://braneshop.com.au"
  <> constField "class" "compressed"
  <> dateField "date" "%B %e, %Y"
  <> dateField "jsDate" "%0Y-%m-%d"
  <> defaultContext



postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags
                       <> postCtx


listContextWith :: Context String -> String -> Context a
listContextWith ctx s = listField s ctx $ do
    identifier <- getUnderlying
    metadata <- getMetadata identifier
    let metas = maybe [] (map trim . splitAll ",") $ lookupString s metadata
    return $ map (\x -> Item (fromFilePath x) x) metas


listContext :: String -> Context a
listContext = listContextWith defaultContext'

