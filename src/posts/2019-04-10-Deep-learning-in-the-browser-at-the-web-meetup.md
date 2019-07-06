---
title: Deep learning in the browser!
author: Noon van der Silk
code: https://github.com/silky/tfjs-fashion-mnist-classifier
preview: Re-cap of Noons talk at <a href="https://www.meetup.com/the-web/events/260211393/">The Web Meetup</a> about how we can deploy deep learning models to the Browser via TensorFlow.js.
image: /images/blog/wmu-1.jpg
tags: talk, tensorflowjs
---

Last night I gave a talk at [The Web
Meetup](https://www.meetup.com/the-web/events/260211393/) on deep learning in
the browser. It was mostly about how to deploy models built TensorFlow to the
browser, by way of TensorFlow.js, but we did manage to try a model on the
[Google Colaboratory](https://colab.research.google.com/), and deploy it to
the browser all in the space of about 5 minutes!

We also discussed a few of the items that I brought up in my recent post about
[deploying models via
TensorFlow.js](/posts/2019-02-08-TensorFlowJS-How-to-easily-deploy-deep-learning-models.html).

<center>
![](/images/blog/wmu-1.jpg)
<br />
Deep learning in the browser! - Presentation at the April Web Meetup.
</center>

Here are the links to the presentation and the code:

<ul class="normal">
<li> Presentation - [Deep learning in the browser!](https://docs.google.com/presentation/d/1_px6paltT1ZHZPKKTK_o-8KWKppremKcwe-5GY94kos/edit) </li>
<li> Online Demo - [tfjs fashion mnist classifier](https://silky.github.io/tfjs-fashion-mnist-classifier/index.html)
<li> Code - <https://github.com/silky/tfjs-fashion-mnist-classifier>
</li>
</ul>

Some of the discussion points from the audience were:

<ul class="normal">
<li>Q: What are some real-world use-cases of TensorFlow.js? (A: I haven't seen
    many applications yet, but they're sure to exist!) </li>
<li>Q: What do you think the scope is for new applications of AI in the
browser? (A: Heaps! We need to play with the tooling to find out what they
    are)</li>
<li>Q: Do the models need to be significantly smaller to run in the browser? (A: 
    Depends if you have a GPU when you run it; but not generally, no. A bit
    smaller, yes. </li>
</ul>

We wrapped up with a few thoughts around the future of UX and AI. Ultimately,
I think this is going to be a field of significant growth and importance, so
now's the time to get into it, if it's of interest to you!

<hr />

If you're looking to adopt AI in your organisation, then check out our
upcoming [AI For Leadership](/ai-for-leadership.html) course!
