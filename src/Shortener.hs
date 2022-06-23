{-# LANGUAGE OverloadedStrings #-}

module Shortener where

import Text.Blaze.Html.Renderer.Text (renderHtml)
import qualified Text.Blaze.Html5 as H
import Web.Scotty

shortener :: IO ()
shortener =
  scotty 3000 $
    get "/" $
      html $ renderHtml $
        H.html $
          H.body $ do
            H.h1 "Shortener"