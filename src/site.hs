--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Control.Applicative
import qualified Data.Set as S
import           Text.Pandoc.Options
import           Control.Monad
import           Hakyll.Web.Diagrams (pandocCompilerDiagrams)
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
                          `mappend` listField "posts" postCtx (return posts)
                          `mappend` constField "class" "compressed"
                          `mappend` defaultContext
                          `mappend` constField "tagCloud" tagCloud
                          `mappend` constField "showreel" "showreel"

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
                          `mappend` listField "posts" postCtx (return posts)
                          `mappend` constField "class" "compressed"
                          `mappend` defaultContext
                          `mappend` constField "tagCloud" tagCloud

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls


        route $ setExtension "html"
        compile $ 
                (pandocMathCompiler)
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= saveSnapshot "content"
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
                    ]) $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= applyAsTemplate defaultContext
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls


    match (fromList ["showreel.html"]) $ do
        route idRoute
        compile $ do
            tags  <- buildTags "showreel/*" (fromCapture "showreel-tags/*.html")
            posts <- recentFirst =<< -- loadAll "showreel/*"
                      loadAllSnapshots "showreel/*" "content"

            let ctx =
                    listField "posts" (postCtxWithTags tags) (return posts)
                    `mappend` postCtx
                    `mappend` bodyField "content"

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
                    listField "posts" (postCtxWithTags tags) (return posts) `mappend`
                    defaultContext

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
                    listField "posts" (postCtxWithTags tags) (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls


    match "templates/*" $ compile templateCompiler


    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<<
                loadAllSnapshots "posts/*" "content"
            renderAtom feedConf feedCtx posts


feedConf :: FeedConfiguration
feedConf = FeedConfiguration
    { feedTitle         = "Braneshop | braneshop.com.au"
    , feedDescription   = "The blog of the Braneshop team."
    , feedAuthorName    = "Braneshop Team"
    , feedAuthorEmail   = "noonsilk+-braneshop@gmail.com"
    , feedRoot          = "https://braneshop.com.au"
    }


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    constField "class" "compressed" `mappend`
    defaultContext


postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx
