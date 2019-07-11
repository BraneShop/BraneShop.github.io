---
link: https://arxiv.org/pdf/1904.07595.pdf
title: Detecting the Unexpected
image: "/images/showreel/Detecting the Unexpected.jpg"
date: 2019-04-16
tags: computer-vision, technical
preview: How do we know what we don't know? Turns out we can know that.
---

This is a really neat and important idea. The application here is in
self-driving cars, but the central idea is very general. The main point is, if
we've trained a network to detect certain classes of thing ("car", "road",
"person", "truck") then, if it sees something completely unexpected,
("goose"), what will it predict? Depending on how you set up the network, it
will predict one of the known classes. This work is about quantifying how
confident the network should feel about such prediction. Their idea is to
ask the network to think about how well it can reconstrut the thing it thought
it saw. If it finds it hard, then that indicates that the thing it saw is
moderately unknown to it, and so it shouldn't be confident. As we have more AI
out in real life making decisions, quantifying uncertainty will become
increasingly important.

