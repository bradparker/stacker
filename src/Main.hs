module Main
  ( main
  ) where

import Codec.Picture
  ( DynamicImage(ImageRGB8)
  , Image(Image)
  , PixelRGB8(PixelRGB8)
  , convertRGB8
  , pixelMap
  , readImage
  , saveJpgImage
  )
import Control.Exception (Exception, throwIO)

convert :: Image PixelRGB8 -> Image PixelRGB8
convert =
  pixelMap
    (\(PixelRGB8 r g b) ->
       let avg = (r + g + b) `div` 3
        in PixelRGB8 avg avg avg)

newtype Error =
  Error String
  deriving (Show)

instance Exception Error

main :: IO ()
main = do
  res <-
    traverse (saveJpgImage 100 "foo.jpg" . ImageRGB8 . convert . convertRGB8) =<<
    readImage "./test-media/chris.jpg"
  case res of
    Right _ -> putStrLn "Wrote: foo.jpg"
    Left e -> throwIO (Error e)
