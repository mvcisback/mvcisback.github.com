---
layout: post
title: Moving_to_Clay
---

I recently discovered [Clay](http://fvisser.nl/clay/), a CSS preprocessor EDSL
in Haskell. Infact this site's CSS is now all generated using Clay! The use
case as the site mentions is similar to LESS and Sass, but with the added
benefit of true _#typeSafety_.

# Usage #
The websites tutorial is very helpful, and more or less get you up and running
in no time. One particularly nice feature is being able to explore the API
using ghci. From there it becauses a matter of matching up types to discover
all of the possible inputs for a function.

Here's a snippet from this site's source:
```haskell
-- stylesheet.hs
myBody = body ?
         do sym margin 0
            sym padding 0
            background (url "../images/bkg.png")
            color "#eaeaea"
            fontSize (px 16)
            lineHeight (pct 150)
            myFontFamily
```

# Caveats #
The EDSL is _almost_ complete, but even I a relative CSS beginner was able to
discover a few holes. 

One feature I found missing was the columns-count and column-gap.
That said, its understandable that it might not be in the library
(being somewhat browser specific) and I may even use it as a chance to get a
pull request in.

Clay, however does give you the ability to by pass its type safety (using (-:))
so I was ultimately able to work around those limitations.

```haskell
-- From resume.hs
listCols = ".col_lis" ** ul ? do
             "-moz-column-count" -: "4"
             "-moz-column-gap" -: "5px"
             "-webkit-column-count" -: "4"
             "-webkit-column-gap" -: "5px"
```

# Conclusion #
So far I've used Clay for this website, my resume, and my upcoming mozilla
intern presentation (along with the infinitely versatile pandoc). I highly
recommend playing with it if you've considered using Sass or LESS and know
even an inkling of Haskell.
