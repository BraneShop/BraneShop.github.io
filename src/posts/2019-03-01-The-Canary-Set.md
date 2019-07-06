---
title: The Canary Set for Machine Learning Applications
author: Noon van der Silk
image: /images/blog/canary-cage-data.png
preview: We introduce a new idea for applied ML applications &mdash; A dataset that the user curates and uses to build confidence in the ML system, the "Canary Set".
tags: tools
---

Earlier this week I was chatting to some people and we came up with a good
idea. It's what I refer to now as the "Canary Set".

We're probably all familiar with the standard "canary in the cage" idea:

<center>
<p>The standard canary in a cage.</p>
![The standard canary in a cage.](/images/blog/canary-cage.png)
</center>

It's an item that can be carried with you into your hazardous job, and when it
dies, it's suggestive that the place your working in is unsafe. Poor canary.

I'd like to propose that this can be a useful idea in machine learning, where
instead of a canary, we carry around an "interesting set" of data:


<center>
<p>A Canary Set of interesting data points.</p>
![A Canary Set of data](/images/blog/canary-cage-data.png)
</center>

This would be called the "Canary Set" of data, and every time a new deployment
of your ML model comes out, you run the mdoel across this dataset to see how
it performs.

<center>
<p>Going in ...</p>
<br/>
![The canary set going through the next version of the AI](/images/blog/canary-cage-ai.png)
<br /> <br />
<p>Coming out with a report ...</p>
<br/>
![The canary set coming out with a report!](/images/blog/canary-cage-ai-out.png)
</center>

Let's go into a few details of why we might want this, how it differs from the
"test" or "validation" set during the training/evaluation phase of machine
learning algorithms, and what benefits we might get from it.

#### The Canary Set: Main Justification

The main point of the canary set is to give **users of your machine learning
service** control over a set of data that they want to evaluate your new
models against. In this way, it differs significantly from the standard "test"
set in that it doesn't need to contain a well-distributed set of samples, it
just needs to contain those samples that the **user** is interested in.

These might be:

<ul class="normal">
<li> Rare inputs, </li>
<li> Inputs for which they are uniquely concerned, as compared to other users,
</li>
<li> "Extreme" inputs, that check areas they are interested in, </li>
<li> A random selection of their past inputs, </li>
<li> ... many more ideas! </li>
</ul>

I think there's a world of options here. The point is: **The user gets some
control**. And this is a nice idea, given that we want them to be gaining
confidence in the ML system.

#### Secondary benefits

Increasingly we're going to see that there will be different environments for
ML training and inference. We've already explored this in our last blog post
on [TensorFlow.js](/posts/2019-02-08-TensorFlowJS-How-to-easily-deploy-deep-learning-models.html),
but there are also the growing number of so-called "edge devices", the [Google
Edge TPU](https://cloud.google.com/edge-tpu/), the
[Movidius](https://www.movidius.com/) and the [JeVois](http://jevois.org/),
among others.

The point is, we can't actually guarantee that when we do testing of our model
during training that it will agree exactly with the inference world, because
there may be many stages in between.

This actually came up on a project I was working on last year.  We trained a
model, and when we deployed it to the cloud, it didn't work well.  We tracked
it down to a bug in the GPU code relating to some post-processing of the
models output. This error was only found becaues I decided it would be a good
idea to test the model on some "real" data, before making it live. In other
words, I made up my own canary set and tested the model on that first, before
making it live.



#### Conclusion

In summary, the idea is that in any machine learning service, for users, that
you build, you could consider adding the facility for the users to be involved
in selecting a set of data that is used to evaluate any new versions of the
models. 

The benefits are:

<ul class="normal">
<li> Increasing user engagement and trust, </li>
<li> finding new interesting edge-cases where your algorithm fails, </li>
<li> and ensuring the quality of inference when you may not be in control of the inference endpoint.
</li>
</ul>

Hope this idea is helpful!
