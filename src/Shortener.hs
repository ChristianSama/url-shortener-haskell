{-# LANGUAGE OverloadedStrings #-}

module Shortener where

import Control.Monad.IO.Class (MonadIO(liftIO))
import Data.Foldable (for_)
import Data.IORef (modifyIORef, newIORef, readIORef)
import Data.Map (Map)
import qualified Data.Map as M
import Text.Blaze.Html.Renderer.Text (renderHtml)
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import Web.Scotty
import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Network.HTTP.Types (status404)
import Database.PostgreSQL.Simple
import Data.Int
import Database.PostgreSQL.Simple.FromRow
import qualified Database.PostgreSQL.Simple.FromField as TL
import Control.Monad (forM_)

-- data Url = Url {id :: Int, url :: Text}

-- instance FromRow Url where
--   fromRow = Url <$> field <*> field

localPG :: ConnectInfo
localPG = defaultConnectInfo
  { connectHost = "localhost"
  , connectDatabase = "shortener"
  , connectUser = "dev"
  , connectPassword = "dev"
  }

shortener :: IO ()
shortener = do
  conn <- connect localPG
  -- urls <- retrieveUrls conn
  -- forM_ urls print

  -- urlsR <- newIORef (1 :: Int, mempty :: Map Int Text)
  scotty 3000 $ do

    get "/" $ do
      -- (_, urls) <- liftIO $ readIORef urlsR
      urls <- liftIO $ retrieveUrls conn
      html $ renderHtml $
        H.html $
          H.body $ do
            H.h1 "Shortener"
            H.form H.! A.method "post" H.! A.action "/" $ do
              H.input H.! A.type_ "text" H.! A.name "url"
              H.input H.! A.type_ "submit"
            H.table $
              for_ urls $ \(i, url) ->
                H.tr $ do
                  H.td (H.toHtml i)
                  H.td (H.text url)

    post "/" $ do
      url <- param "url"
      -- liftIO $ modifyIORef urlsR $
        -- \(i, urls) ->
        --   (i + 1, M.insert i url urls)
      _ <- liftIO $ createUrl conn url
      redirect "/"

    get "/:index" $ do
      n <- param "index"
      -- (_, urls) <- liftIO $ readIORef urlsR
      -- case M.lookup n urls of
      --   Just url ->
      --     redirect (LT.fromStrict url)
      --   Nothing ->
      --     raiseStatus status404 "not found"
      res <- liftIO $ retrieveUrl conn n
      redirect $ LT.fromStrict $ snd $ head res

retrieveUrl :: Connection -> Int -> IO [(Int, Text)]
retrieveUrl conn id = do
  query conn "SELECT * FROM original_url WHERE id = (?)" $ Only id

retrieveUrls :: Connection -> IO [(Int, Text)]
retrieveUrls conn = do
  query_ conn "SELECT * FROM original_url"

createUrl :: Connection -> String -> IO [Only Int]
createUrl conn newUrl =
  query conn "INSERT INTO original_url (url) VALUES (?) RETURNING id" $ Only newUrl