---
link: https://arxiv.org/pdf/1907.04572.pdf
title: Out-of-Distribution Detection using Generative Models
image: "/images/showreel/Out-of-Distribution Detection using Generative Models.jpg"
date: 2019-07-10
tags: generative, technical
preview: Generative models can be used to work out if we're seeing some data that we were never trained on.
---

[In an old blogpost](/posts/2018-12-17-How-Much-Data-For-Retraining.html) we
discussed the problem of networks making over-confident predictions. This
paper focused on over-confidence on images that the network has _never_ seen
(i.e. trained on cats and dogs, then very confident that a picture of a boat
 is a dog).

A classical idea (we saw it in the "Detecting the Unexpected" paper) is that
if we think about how well we can _reconstruct_ a given image, that might tell
us something about how often our network has seen it; i.e. if it's
"in-dstribution" or not.

This paper notes that one problem with that idea is that if the thing we're
looking at is "simple" (technically, has "small variance"), then because the
generative models are powerful, they might still do a good job.

The approach they provide in the paper is to use a different kind of
generative network, the so-called "Neural Rendering Model (NRM)", to do the
image generation, and that this new technique just happens to be better at
being informative when the data is from a set the network has never seen.

The picture above shows that the NRM-approach does quite a good job of
seperating between images the network has seen and hasn't seen.

This is a bit of a technical result, but it's a crucially important area
of research for networks that are going to be used in the real world.
