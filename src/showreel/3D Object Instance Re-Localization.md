---
link: https://arxiv.org/pdf/1908.06109.pdf
title: 3D Object Instance Re-Localization
image: /images/showreel/3D Object Instance Re-Localization.jpg
date: 2019-08-16
tags: computer-vision
preview: Having found a 3D object before, can we find it again in a new view?
---

This is an odd one but probably important to someone. Suppose that you can
compute a 3D object instance segmentation. I.e. you can locate where an object
is in 3D. Then, given a _different view_ of the scene, can you find the
objects again? This is important, probably, because succeeding at the instance
segmentation at arbitrary views of the scene is harder, you might think, then
if you use your prior knowledge about the objects positions, having seen them
before.

For me this is an interesting work related to the general idea of "temporal
coherence"; i.e. using knowledge that we know from a previous timestep at a
new timestep.
