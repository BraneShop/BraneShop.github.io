--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

import           Data.Monoid ((<>), mconcat)
import           Hakyll
import           Control.Applicative
import qualified Data.Set as S
import qualified Data.Map as M
import           Text.Pandoc.Options
import           Control.Monad
import           Hakyll.Web.Diagrams (pandocCompilerDiagrams)
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
                          <> defaultContext
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
                          <> defaultContext
                          <> constField "tagCloud" tagCloud

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls


        route $ setExtension "html"
        compile $ 
                pandocMathCompiler
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
                  <> defaultContext

        compile $ do
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
                    <> defaultContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match (fromList ["poster.html"]) $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= applyAsTemplate defaultContext
                >>= loadAndApplyTemplate "templates/branded.html" defaultContext
                >>= relativizeUrls


    match (fromList [ "index.html"
                    ]) $ do
        route idRoute
        compile $ do
            posts <- fmap (take 4) . recentFirst =<< loadAll "posts/*"
            tags <- buildTags "posts/*" (fromCapture "tags/*.html")

            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    <> defaultContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
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
    dateField "date" "%B %e, %Y"
    <> constField "class" "compressed"
    <> teaserField "teaser" "content"
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
listContext = listContextWith defaultContext

