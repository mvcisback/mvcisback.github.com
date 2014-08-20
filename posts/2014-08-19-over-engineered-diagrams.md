---
layout: post
title: Over Engineered SVGs
---

For my upcoming intern presentation, I've started playing with the (diagrams)[http://projects.haskell.org/diagrams/]
DSL again.

I specifically 2 diagrams for 2 pipelines. Rather than just opening up inkscape and making the chart
(a process that would likely have taken 10 minutes), I instead opted to write the following Haskell
code to generate the pipeline svg.

```haskell
node name text' = square 1 # named name
            `atop`
            text text' # scale (1/4)

createChain :: [String] -> QDiagram B R2 Any
createChain nodes = strutX 0.2 ||| arrows chart ||| strutX 0.2
    where
       chart = hcat $ intersperse (strutX 1) nodes'
       arrows = foldr (.) id arrows'
       arrows' = zipWith connectOutside idents (tail idents)
       idents = map show [1..(length nodes)]
       pairWise = zip idents (tail idents)
       nodes' = zipWith node idents nodes
```

For the input `["x", "y", "z"]` this generates

![](/images/chain.svg)

Was it worth it? Probably not... Is it cool? I think so, otherwise I wouldn't have posted it. :p
