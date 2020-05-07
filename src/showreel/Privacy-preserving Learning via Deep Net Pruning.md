---
link: https://arxiv.org/pdf/2003.01876.pdf
title: Privacy-preserving Learning via Deep Net Pruning
image: /images/showreel/Privacy-preserving Learning via Deep Net Pruning.jpg
date: 2020-03-04
tags: privacy, technical
preview: A relationshpi between data privacy and pruning.
---

This is interesting paper in that it shows how "differential privacy" can be
related to network pruning. Differential privacy is the idea that we can hide
individual datapoints by adding noise. This is useful if, say, working on
medical data where we want to not reveal individual patients.

The trade-off is between how much worse does the network get as we increase
the privacy (i.e. make it harder to recover individual datapoints). This paper
links this idea with the idea of pruning neural networks in a precise way.

