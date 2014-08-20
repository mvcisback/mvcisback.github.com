{-# LANGUAGE OverloadedStrings #-}

import Clay
import Data.Text hiding (center)
import Data.Monoid
import Prelude hiding ((**))

main :: IO ()
main = putCss myStylesheet

myFonts = ["Monaco", "Bitstream Vera Sans Mono", "Lucida Console", "Terminal"]
myFontFamily = fontFamily myFonts [monospace]

myColor = "#b5e853"
myAlpha = 26

myBody = body ?
         do sym margin 0
            sym padding 0
            background (url "../images/bkg.png")
            color "#eaeaea"
            fontSize (px 16)
            lineHeight (pct 150)
            myFontFamily

mySection = section ?
            do display block
               margin 0 0 (px 20) 0

containerClass = star # byClass "container" ?
                 do width $ pct 90
                    maxWidth $ px 600
                    sym2 margin 0 auto

hSelectors = h1 <> h2 <> h3 <> h4 <> h5 <> h6 ?
             do margin 0 0 (px 20) 0
                color myColor
                fontWeight normal
                letterSpacing (em $ -0.03)
                textShadow 0 (px 1) (px 1) (rgba 0 0 0 myAlpha)

myLi = li ? lineHeight (pct 140)

container = header ?
           do backgroundColor (rgba 0 0 0 myAlpha)
              width (pct 100)
              borderBottom dashed (px 1) myColor
              sym2 padding (px 20) 0
              margin 0 0 (px 40) 0
              textAlign $ center

projectName = header ** h1 ?
              do fontSize (px 30)
                 lineHeight (pct 150)
                 margin 0 0 0 (px $ -40)
                 fontWeight bold
                 textShadow 0 (px 1) (px 1) (rgba 0 0 0 myAlpha) -- TODO ask eric about ,
                 letterSpacing (px $ -1)

projectDescription = header ** h2 ?
                     do fontSize (px 18)
                        fontWeight $ weight 300
                        color "#666"

center = alignSide sideCenter

mainContent = do mainContentSelector <> h1 ? fontSize (px 30)
                 mainContentSelector <> h2 ? fontSize (px 24)
                 mainContentSelector <> h3 ? fontSize (px 18)
                 mainContentSelector <> h4 ? fontSize (px 14)
                 mainContentSelector <> h5 ? highOrderCSS
                 mainContentSelector <> h6 ? highOrderCSS
    where mainContentSelector = star # byId "main_content"
          highOrderCSS = fontSize (px 12)
                         >> textTransform uppercase
                         >> color "#999"
                         >> margin 0 0 (px 5) 0

beforeUlLi = ul ** li # before ?
             do content $ stringContent ">>"
                fontSize (px 13)
                color myColor
                marginLeft (px $ -37)
                marginRight (px 21)
                lineHeight (px 16)

myBlockQuote = blockquote ?
               do color "#aaa"
                  paddingLeft (px 10)
                  borderLeft dotted (px 1) "#666"

myPre = pre ?
        do background $ rgba 0 0 0 230
           border solid (px 1) $ rgba 255 255 255 38
           sym padding (px 10)
           fontSize (px 14)
           color myColor
           sym borderRadius (px 2)
           overflow auto
           overflowY hidden


myTable = do table ? do width (pct 100)
                        margin 0 0 (px 20) 0
             th ? do textAlign $ alignSide sideLeft
                     borderBottom dashed (px 1) myColor
                     sym2 padding (px 5) (px 10)
             td ? sym2 padding (px 5) (px 10)

myHR = hr ?
       do height (px 0)
          border dashed (px 0) black
          borderBottom dashed (px 1) myColor
          color myColor

myLink = a ? (color "#63c0f5" >> textShadow 0 0 (px 5) (rgba 104 182 255 127))

myFooter = star # byClass "footer" ?
           do borderTop dashed (px 1) myColor
              sym2 padding (px 20) 0
              margin (px 40) 0 (px 40) 0
              textAlign $ center

myStylesheet :: Css
myStylesheet = myBody
               >> mySection
               >> containerClass
               >> hSelectors
               >> myLi
               >> container
               >> projectName
               >> projectDescription
               >> mainContent
               >> (dt ? (fontStyle italic >> fontWeight bold))
               >> (ul ** li ? listStyleType none)
               >> beforeUlLi
               >> myBlockQuote
               >> myPre
               >> myTable
               >> myHR
               >> myLink
               >> myFooter
               >> (img ? (backgroundColor white >> width (pct 100)))

