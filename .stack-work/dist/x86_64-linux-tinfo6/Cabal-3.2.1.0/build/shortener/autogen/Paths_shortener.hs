{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_shortener (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/bin"
libdir     = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/lib/x86_64-linux-ghc-8.10.7/shortener-0.1.0.0-G3UjJZn6AHJIiVlJwQ4GE-shortener"
dynlibdir  = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/lib/x86_64-linux-ghc-8.10.7"
datadir    = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/share/x86_64-linux-ghc-8.10.7/shortener-0.1.0.0"
libexecdir = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/libexec/x86_64-linux-ghc-8.10.7/shortener-0.1.0.0"
sysconfdir = "/home/csamaniego/Code/shortener/.stack-work/install/x86_64-linux-tinfo6/fbc2ee25999ba049b7c32bcdde7ef267f0882c450d6c295d032841a50eaa7b2e/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "shortener_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "shortener_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "shortener_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "shortener_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "shortener_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "shortener_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
