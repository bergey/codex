{-# language OverloadedStrings #-}
import Control.Concurrent
import qualified Data.ByteString as BS
import Data.Foldable
import Data.Watch
import Data.Watch.FilePath
import System.Directory
import System.FilePath
import Test.Hspec as Hspec
import Test.Tasty
import Test.Tasty.Hspec

scratchDir :: FilePath
scratchDir = "test/scratch"

emptyScratch :: IO ()
emptyScratch = do
  xs <- listDirectory scratchDir
  for_ (filter (\x -> head x /= '.') xs) $ \x -> do
    removeFile $ scratchDir </> x

io :: IO r -> IO r
io = id

spec :: Spec
spec = before_ emptyScratch $ Hspec.after_ emptyScratch $ do
  it "starts/stops" $ do
    x <- withFileWatcher $ \w -> do pure 0
    x `shouldBe` 0
  it "sees changes" $ io $ do
    withFileWatcher $ \w -> do
      listenToTree w scratchDir
      let file = scratchDir </> "x"
      doesFileExist file `shouldReturn` False
      thunk <- readWatchedFile w file
      force thunk `shouldThrow` anyIOException
      force thunk `shouldThrow` anyIOException
      writeFile file "hello"
      force thunk `shouldReturn` "hello"
      len <- delay $ BS.length <$> force thunk 
      force len `shouldReturn` 5
      force len `shouldReturn` 5
      writeFile file "bye"
      threadDelay 1000000 -- 1 second
      force len `shouldReturn` 3
      
main :: IO ()
main = do
  spec' <- testSpec "spec" spec
  defaultMain spec'