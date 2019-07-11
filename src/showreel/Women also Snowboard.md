---
link: https://arxiv.org/pdf/1803.09797.pdf
title: Women also Snowboard
image: "/images/showreel/Women also Snowboard.jpg"
date: 2018-03-26
tags: ethics, technical
preview: Techniques to help models be less biased.
---

This is a famous and interesting paper. They identify a common problem in
so-called "captioning" networks: namely, they can be right for the wrong
reasons. In the photo, we see that a network guesed it was a man sitting at a
computer; but it only spent time "looking" at the computer to work this out.
In other words, a computer was strongly correlated with the photo being of "a
man at the computer" in the training data. In this paper they introduce some
techniques to deal with this problem. Basically, their idea is that we can
penalise the network for thinking about gender when no gender information is
present, and reward it for thinking about gender when it _is_ apparent.
Furthermore, their approach is generally useful for other models and
situations.

We can expect more technical results in this area to be implemented alongside
the social techniques (i.e. having more diverse people involved in the
building of AI systems).


