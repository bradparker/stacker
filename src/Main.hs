module Main
  ( main
  ) where

import Codec.Picture
  ( DynamicImage(ImageRGB8)
  , Image(Image)
  , PixelRGB8(PixelRGB8)
  , convertRGB8
  , readImage
  , saveJpgImage
  )
import Codec.Picture.Types (pixelMapXY)
import Control.Exception (Exception, throwIO)

hatch :: Int -> Int -> PixelRGB8 -> PixelRGB8
hatch x y px = px

crunch :: PixelRGB8 -> PixelRGB8
crunch (PixelRGB8 r g b) =
  PixelRGB8 ((r `div` 50) * 50) ((g `div` 50) * 50) ((b `div` 50) * 50)

greyscale :: PixelRGB8 -> PixelRGB8
greyscale (PixelRGB8 r g b) = PixelRGB8 avg avg avg
  where
    avg =
      fromIntegral ((fromIntegral r + fromIntegral g + fromIntegral b) `div` 3)

convert :: Image PixelRGB8 -> Image PixelRGB8
convert = pixelMapXY (\x y -> hatch x y . crunch . greyscale)

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
