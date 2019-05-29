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

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ 
                (pandocMathCompiler)
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match (fromList ["deep-learning-workshop.html"
                    , "ai-for-leadership.html"
                    , "6-week-workshop-on-deep-learning.html"
                    , "faq.html"
                    ]) $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= applyAsTemplate defaultContext
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    match (fromList ["blog.html"]) $ do
        route idRoute
        compile $ do
            posts <- (liftM (take 10)) $ recentFirst =<< loadAll "posts/*"
            let ctx =
                    listField "posts" postCtx (return posts) `mappend`
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

    match (fromList ["index.html", "team.html", "contact.html", "community.html"]) $ do
        route idRoute
        compile $ do
            -- posts <- (liftM (take 10)) $ recentFirst =<< loadAll "posts/*"
            -- let indexCtx =
            --         listField "posts" postCtx (return posts) `mappend`
            --         defaultContext

            getResourceBody
                >>= applyAsTemplate defaultContext
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
