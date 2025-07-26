--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "papers/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["contact.md", "cv.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "publication.md" $ do 
        compile pandocCompiler

    match "talks.md" $ do 
        compile pandocCompiler

    match "index.html" $ do
        route idRoute
        compile $ do
            publicationContext <- publicationCtx 
            talksContext <- talksCtx

            let context = publicationContext <> talksContext <> defaultContext

            getResourceBody
                >>= applyAsTemplate context 
                >>= loadAndApplyTemplate "templates/default.html" context
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------

publicationCtx :: Compiler (Context String)
publicationCtx = do
  html <- loadBody "publication.md" 
  return $ constField "publication" html

talksCtx :: Compiler (Context String)
talksCtx = do
  html <- loadBody "talks.md" 
  return $ constField "talks" html

config :: Configuration 
config = defaultConfiguration
    { destinationDirectory = "docs" }
