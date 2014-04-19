module Paths_mvcisback_github_com (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch


version :: Version
version = Version {versionBranch = [0,1,0,0], versionTags = []}
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/mvc/work/mvcisback.github.com/.cabal-sandbox/bin"
libdir     = "/home/mvc/work/mvcisback.github.com/.cabal-sandbox/lib/x86_64-linux-ghc-7.8.3/mvcisback-github-com-0.1.0.0"
datadir    = "/home/mvc/work/mvcisback.github.com/.cabal-sandbox/share/x86_64-linux-ghc-7.8.3/mvcisback-github-com-0.1.0.0"
libexecdir = "/home/mvc/work/mvcisback.github.com/.cabal-sandbox/libexec"
sysconfdir = "/home/mvc/work/mvcisback.github.com/.cabal-sandbox/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "mvcisback_github_com_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "mvcisback_github_com_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "mvcisback_github_com_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "mvcisback_github_com_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "mvcisback_github_com_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
