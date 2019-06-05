---
title: State of the art attention models in PyText
author: Noon van der Silk
draft: True
---

I wanted to take some time to discuss a library that seems to have flown under
the radar a little bit. It's called
[PyText](https://github.com/facebookresearch/pytext), and I want to explore
how you can use it to run state of the art attention models.

We're going to proceed in the following way:

1. Set a dataset,
2. See how we prepare the data for training in PyText,
3. Get PyText,
4. Train it,
5. Visualise it,
6. Consider extension,

Finally, we'll jump in to a fork of PyText where I've added a few features
that help out during training.


