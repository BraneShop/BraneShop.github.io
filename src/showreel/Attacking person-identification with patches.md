---
link: https://arxiv.org/pdf/1904.08653.pdf
title: Attacking person-identification with patches
image: "/images/showreel/Attacking person-identification with patches.jpg"
date: 2019-04-18
tags: computer-vision, privacy
preview: A graphic that can be printed that can prevent a certain algorithm from spotting you!
---

The game in this one is - can we make a picture, that can be printed and held
in front of us, that will fool a person-detector? Yes, it turns out. 

This is refered to as an "adversarial" attack, and they have gained a lot of
attention recently. This one in particular is interesting because they attack
a standard person-detector (so-called "Yolo") and the image they use is
"local" and "printable". There had been a few results in this area, but
nothing attacking person detectors.

In the research world, we're seeing work on both fronts. There are a lot of
work on how to do more of these, and make them more robust, and likewise there
is a lot of work on how to make classifiers and detectors less vulnerable to
such attacks. Who will win? It's not clear. I'd put my money on it always
being possible to make such attacks, given enough information on the
classifier. But, the cost of such attacks will rise significantly, making it
unfeasible for most of us.
