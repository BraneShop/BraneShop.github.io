---
title: Mindful Neural Networks
author: Noon van der Silk
image: /images/blog/thich-nhat-tanh.png
preview: Through the <a href="https://www.meetup.com/Melbourne-Creative-AI-Meetup/">Creative AI Meetup</a> we explored ideas at the intersection of mindfulness and neural networks.
---

Last night at the [Creative AI
Meetup](https://www.meetup.com/Melbourne-Creative-AI-Meetup/) we had an awesome
conversation around the idea of "Mindful" neural networks.

<center>
<img width="600" src="/images/blog/thich-nhat-tanh.png" />
<br />
<i>Thich Nhat Tanh</i>
</center>

We were hosted by our friends at [Sheda](https://sheda.ltd) over the
[Neighbourhood.work](https://neighbourhood.work) in Fitzroy, and we had a
really nice group of people with varied and interesting backgrounds show up:

<center>
<a href="/images/blog/creative-ai-march-2019.jpg"><img width="600" src="/images/blog/creative-ai-march-2019.jpg" /></a>
<br />
<i>The Mindful Neural Network Group. Photo courtesy of Eike!</i>
</center>

We did the usual Creative-AI opening where we review a bunch of recent
innovations in the field in the last few weeks. You can find the projects we
discussed by looking over the slides here: [Creative AI Meetup - March
2019](https://docs.google.com/presentation/d/167A6XXp9NIOb0tPTls51PveyMgKjGEEpKaeospVr54g/edit).

Most notable were the variety of "this X does not exist" websites powered by
[StyleGAN](https://github.com/NVlabs/stylegan):

<ul class="normal">
  <li>Person:  <https://thispersondoesnotexist.com> </li>
  <li>Cat: <https://thiscatdoesnotexist.com> </li>
  <li>Airbnb: <https://thisrentaldoesnotexist.com> </li>
</ul>

and the [GPT-2 model](https://github.com/openai/gpt-2), which produced the
following gem, when prompted with a segment of [when things fall
apart](https://www.goodreads.com/book/show/687278.When_Things_Fall_Apart):
    
```
Input  >>>

To be fully alive, fully human, and completely awake is to be


Output >>>

completely free from judgement and morality, to have freedom in any worldview
through suffering (with anything that comes from between two extremes can
often be fine), to be absolutely free from stimuli getting in your way,
to be completely free from fear and humiliation, to be completely free
from a series of simple pleasures, to be absolutely free from your own
emotional and social dependence inherent in anything being different
from yours. [...]
```

We did eventually got around to discussing the mindfulness aspect of neural
networks, and what ideas we thought we could transfer over.

As a group, we covered:

<ul class="normal">
<li> **Attention**: [Is attention
enough?](https://scirate.com/arxiv/1706.03762) Should we make our networks
"aware" of their own thoughts? Is that te same as "attention" as-it's
implemented presently? We discussed briefly this paper: [Attention is not
Explanation](https://scirate.com/arxiv/1902.10186).
</li>
<li> **Anxiety**: We discussed anxiety as "fear of the future",
and considered that perhaps neural nets have no awareness of the future, as
they only make judgements on single instance, or alternatively the
interpretation that actually neural networks are incredibly anxious as during
training that are entirely focused on the future, and how they can change
themselves to do better.
</li>
<li> **Presence**: We wondered whether neural networks are "present" in "the
moment", or if this even makes sense.
</li>
<li> **Consciousness**: We didn't go too in-depth on this, but we happened to
have a [researcher working in this area in the
room](https://www.linkedin.com/in/rafik-hadfi/), so we discussed it on an off.
We did discuss our favourite reading on the topic. On free will, mine is this
[The Ghost in the Quantum Turing Machine](https://arxiv.org/abs/1306.0159),
and on consciouness and thinking it is [I Am a Strange
Loop](https://www.goodreads.com/book/show/123471.I_Am_a_Strange_Loop), [Gödel,
Escher, Bach](https://www.goodreads.com/book/show/24113.G_del_Escher_Bach),
and [Surfaces and
Essences](https://www.goodreads.com/book/show/7711871-surfaces-and-essences)
(the last of which I covered on [my 2018 reading
 list](https://silky.github.io/posts/2019-01-03-2018-books.html)).
</li>
<li> **Intent**: We talked a little bit about how it's important to know _why_
a given dataset was constructed, as this might lead to us understanding it's
bias.
</li>
<li> **[Paramitas](https://en.wikipedia.org/wiki/P%C4%81ramit%C4%81)/Loss Functions**: We had a moderate amount of discussion
around how "small" most neural networks are in their output objective. They
take in significantly rich data, but force it to be absolutely 1 or absolutely
0. Maybe there could be richer loss functions we could consider, that would
allow for the network to focus in different ways. A recent bit of research
along these lines is this: [Completment Objective
Training](https://scirate.com/arxiv/1903.01182), i.e. have it make a good
prediction of what it is, but also what it is _not_.
</li>
</ul>

Overall, I had heaps of fun, and there was some discussion of a second
installment, as there is heaps to explore here, so stay tuned to the
[meetup](https://www.meetup.com/Melbourne-Creative-AI-Meetup/) and join us next
time!
