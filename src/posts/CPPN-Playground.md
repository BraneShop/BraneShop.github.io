---
title: Introducing the CPPN Playground!
author: Noon van der Silk
image: /images/blog/cppn-playground.jpg
imageDescription: The main interface of the CPPN playground; reproducing a cool rendering of a black hole.
date: 2019-10-23
preview: A fun little neural-network-based tool to make cool pictures!
tags: announcement, tool
---

As we saw in the [business card blog post](/posts/Non-Technical-But-Detailed-Explanation-Of-Our-Business-Card-Designs.html)
we love "CPPNs" here. 

We wanted to share the fun, so I made a little JavaScript app where you can
play around with them. You can access it here: [CPPN
Playground](https://silky.github.io/cppn-playground/).

There's a few main things you can do:

1. Look at the cool pictures! And adjust the network to get more.
2. Train the network to reproduce a specific picture.
3. Download a big (1000x1000) version of the image!

<!--more-->

Here's a big version of the black hole image:

<center><img src="/images/blog/black-hole-big.jpg" /></center>

The way it works is almost exactly as laid out in the business card post. The
reason we're able to <i>reproduce</i> images is that we use the machinery of deep
learning to ask the network to <i>match</i> a given image.

Over time I'll add a better explanation to the page, but for now I just wanted
to get it out there so people can have a go and give some feedback!

It's also [open-source](https://github.com/silky/cppn-playground/tree/master),
built using [TensorFlow.js](https://www.tensorflow.org/js) and
[Elm](https://elm-lang.org/), so feel free to clone it and hack around.
There's plenty more features to add! (I've put a list at the bottom of the
readme).

Hope you enjoy it!

Reach out if you have any questions/comments/suggestions!
