---
link: https://arxiv.org/pdf/2004.15021.pdf
title: Consistent Video Depth Estimation
image: /images/showreel/Consistent Video Depth Estimation.jpg
date: 2020-04-30
tags: technical, video
preview: Making consistent predictions on video.
---

This is an interesting one. The idea is that we want to predict a "consistent"
depth over the frames of a video. If we naively treat each frame as an
independent image, we get very bad consistency; i.e. if we're moving the
camera across a scene; the depth changes wildly.

In the paper they introduce a technique to solve this problem, which then
allows for very cool applications! Check out the
[videos](https://roxanneluo.github.io/Consistent-Video-Depth-Estimation/).

