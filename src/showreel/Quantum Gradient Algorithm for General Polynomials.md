---
link: https://arxiv.org/pdf/2004.11086.pdf
title: Quantum Gradient Algorithm for General Polynomials
image: /images/showreel/Quantum Gradient Algorithm for General Polynomials.jpg
date: 2020-04-23
tags: quantum
preview: A step towards quantum gradient descent for neural networks.
---

The idea here is that, in principle, if you have a lot of parameters in your
function, then the time to compute the entire gradient w.r.t. all the
parameters will scale like the number of parameters. This is bad when you have
billions of parameters; so mostly in optimisation we focus on _stochastic_
gradient descent; i.e. just looking at a small number of parameters at any one
time.

Here, the idea is that we could use quantum computers to do the full
computation significantly faster. In this, and algorithm is introduced that
in fact achieves this, for general polynomials (perhaps a step towards
achieving it for full neural networks).
