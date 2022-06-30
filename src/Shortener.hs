{-# LANGUAGE OverloadedStrings #-}

module Shortener where

import Text.Blaze.Html.Renderer.Text (renderHtml)
import Control.Monad.IO.Class (MonadIO(liftIO))
import Network.HTTP.Types (status404)
import Database.PostgreSQL.Simple
import Data.Foldable (for_)
import Data.Text (Text)
import Web.Scotty
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html5 as H
import qualified Data.Text.Lazy as LT
import qualified Data.Configurator as C
import qualified Data.Configurator.Types as C

data DbConfig = DbConfig {
  dbHost :: String,
  dbName :: String,
  dbUser :: String,
  dbPassword :: String
  }

createDbConfig :: C.Config -> IO (Maybe DbConfig)
createDbConfig cfg = do
  host <- C.lookup cfg "database.host" :: IO (Maybe String)
  name <- C.lookup cfg "database.name" :: IO (Maybe String)
  user <- C.lookup cfg "database.user" :: IO (Maybe String)
  password <- C.lookup cfg "database.password" :: IO (Maybe String)
  return $ DbConfig <$> host <*> name <*> user <*> password

createConnection :: DbConfig -> IO Connection
createConnection dbCfg = connect defaultConnectInfo
                               { connectUser = dbUser dbCfg
                               , connectPassword = dbPassword dbCfg
                               , connectDatabase = dbName dbCfg
                               }

shortener :: IO ()
shortener = do
  loadedConf <- C.load [C.Required "application.conf"]
  dbConf <- createDbConfig loadedConf

  case dbConf of
    Nothing -> putStrLn "No database configuration file"
    Just conf -> do
      conn <- createConnection conf
      scotty 3000 $ do

        get "/" $ do
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
          _ <- liftIO $ createUrl conn url
          redirect "/"

        get "/:index" $ do
          n <- param "index"
          res <- liftIO $ retrieveUrl conn n
          case res of
            [] -> raiseStatus status404 "not found"
            _ -> redirect $ LT.fromStrict $ snd $ head res

retrieveUrl :: Connection -> Int -> IO [(Int, Text)]
retrieveUrl conn id = do
  query conn "SELECT * FROM original_url WHERE id = (?)" $ Only id

retrieveUrls :: Connection -> IO [(Int, Text)]
retrieveUrls conn = do
  query_ conn "SELECT * FROM original_url"

createUrl :: Connection -> String -> IO [Only Int]
createUrl conn newUrl =
  query conn "INSERT INTO original_url (url) VALUES (?) RETURNING id" $ Only newUrl