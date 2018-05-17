module Main
  ( main
  ) where

import Codec.Picture
  ( DynamicImage(ImageRGB8)
  , Image
  , PixelRGB8(PixelRGB8)
  , convertRGB8
  , readImage
  , saveJpgImage
  )
import Codec.Picture.Types (pixelMapXY)
import Control.Exception (Exception, throwIO)
import Data.Semigroup ((<>))
import Options.Applicative
  ( Parser
  , customExecParser
  , fullDesc
  , header
  , helper
  , info
  , long
  , option
  , prefs
  , short
  , showHelpOnError
  , str
  )

lineAt :: Int -> Int -> Int -> Bool
lineAt thickness gap y = any ((0 ==) . (`mod` gap)) (map (+ y) [0 .. thickness])

hatch :: Int -> PixelRGB8 -> PixelRGB8
hatch _ (PixelRGB8 0 0 0) = PixelRGB8 0 0 0
hatch y (PixelRGB8 50 50 50)
  | lineAt 1 4 y = PixelRGB8 0 0 0
  | otherwise = PixelRGB8 255 255 255
hatch y (PixelRGB8 100 100 100)
  | lineAt 0 8 y = PixelRGB8 0 0 0
  | otherwise = PixelRGB8 255 255 255
hatch _ (PixelRGB8 150 150 150) = PixelRGB8 255 255 255
hatch _ (PixelRGB8 200 200 200) = PixelRGB8 255 255 255
hatch _ (PixelRGB8 250 250 250) = PixelRGB8 255 255 255
hatch _ px = px

crunch :: PixelRGB8 -> PixelRGB8
crunch (PixelRGB8 r g b) =
  PixelRGB8 ((r `div` 50) * 50) ((g `div` 50) * 50) ((b `div` 50) * 50)

greyscale :: PixelRGB8 -> PixelRGB8
greyscale (PixelRGB8 r g b) = PixelRGB8 avg avg avg
  where
    avg =
      fromIntegral
        (floor
           (((fromIntegral r :: Float) * 0.21) +
            ((fromIntegral g :: Float) * 0.72) +
            ((fromIntegral b :: Float) * 0.07)) :: Int)

convert :: Image PixelRGB8 -> Image PixelRGB8
convert = pixelMapXY (\_ y -> hatch y . crunch . greyscale)

newtype Error =
  Error String
  deriving (Show)

instance Exception Error

data Options = Options
  { input :: String
  , output :: String
  }

optionsParser :: Parser Options
optionsParser =
  Options <$> option str (short 'i' <> long "input") <*>
  option str (short 'o' <> long "output")

getOptions :: IO Options
getOptions =
  customExecParser
    (prefs showHelpOnError)
    (info
       (helper <*> optionsParser)
       (header "Stacker - image thingy" <> fullDesc))

main :: IO ()
main = do
  opts <- getOptions
  image <- readImage (input opts)
  res <-
    traverse
      (saveJpgImage 100 (output opts) . ImageRGB8 . convert . convertRGB8)
      image
  case res of
    Right _ -> putStrLn ("Wrote: " <> output opts)
    Left e -> throwIO (Error e)
