---
title: TensorFlow.js - How to easily deploy deep learning models
author: Noon van der Silk
---

In the following we'll suppose you've trained a model in Python, and are now
considering how to "productionise" the inference. 


#### You've got a model, how to deploy it?

Once we've built a deep learning model, the next thing we natually want to do
is deploy it to the people that want to use it. 

We can typically make this as hard as we like, by first of all just building
say a simple, say in Python, flask API endpoint, `/inference`, that will take
in a json blob, and then push it into our model, and push back an inference:

<center>
![](/images/blog/inference.jpg)
</center>

To something quite elaborate with various Amazon servers, Azure servers,
Google servers, or the myriad other services providing deep learning
inference and hosted model capability.

But there are a few problems with this approach:

<ul class="norml">
<li> You need a significant dev-ops capability to manage just the
   operating-system and data-management capabilities,
</li>
<li> You need GPU resources (virtual or otherwise) to allocate for the
   inference,
</li>
<li> Even having the GPU capability, you need to manage versioning
   of your models, how to swap them out,
</li>
<li> And, you need to know how to ration and allocate the GPU
   resources between all your inference servers,
</li>
</ul>

The point is, there's much to do. In my exerience, this is infact a
significant barrier/expense in deploying ML in production today.

Now, it may turn out that in your world you _need_ to do this kind of
deployment. But what I would like to think about briefly, is another approach
...


#### Have you considered ... JavaScript?


So, what if I told you that you don't need to set up any computers, and that
in fact the computers you use will be entirely managed and set up by other
people!? Great! What's the catch? Well, you need to use JavaScript ...

<center>
![](/images/blog/tfjs.png)
</center>

The setup is that you want to do some inference on a "small" amount of
user-supplied data. I.e. an image, a passage of text, even a video, or a piece
of audio, but perhaps not 5GB of satellite images.

Then, the plan is like so:

<ul class="normal">
  <li>You train your model as you typically would (in TensorFlow, let's say),</li>
  <li>You export the weights,</li>
  <li>You build the "inference" part of your model in TensorFlow.js</li>
  <li>The model runs in the browser,</li>
  <li>That's it!</li>
</ul>


The main idea is, just as we can build our entire model in TensorFlow, we can
build the so-called "forward" part of our model in TensorFlow.js; that is,
just those parts that are needed for inference, and not the parts are
necessary for training and to support training. Then, we simply rebuild that
part of our model using the TensorFlow.js standard library (such as `tanh`
layers, or whatever our particular network requires).

Then, if we've stayed in the TensorFlow ecosystem it's quite easy, we can just
load in our weights basically immediately, but even if we haven't, ultimately
we can always map our exported weights into our network.

Once that's done, you're basically done. You only need to work out how to get
your data into the browser to do inference on. Typically, if you're working
with images or video, this is easy. You can use the webcam, if you want a live
stream, and really the world is your oyster in all the typical ways that it is
on the web.

#### The upsides and downsides

The upsides are:

<ul class="normal">
<li> The model doesn't run on your hardware ⇒ less resources required to deploy.</li>
<li> Can utilise the exact same deployment and versioning techniques
<small>(with large static content; namely the weights)</small> that you use
for standard websites, which are tried and tested .</li>
<li> If the model is fast enough, can allow for very powerful "live"
interaction by users. </li>
<li> Incredibly portable, as it runs in the browser, it can run on phones,
small laptops, laptops with GPUs (and utilise those GPUs) and can be run
entirely offline.
</li>
</ul>


The downsides are:

<ul class="normal">
<li> You need to maintain a consistency between your Python models and your
JavaScript models. </li>
<li> Because the model doesn't run on hardware you control, the speed
of inference can vary wildly.
</li>
<li> In order to deal with the speed issue, we typically run a
"smaller" or "compressed" model in the browser, which can be
less accurate</li>
</ul>


#### Final thoughts

Browser-based deep learning won't be for everyone, but my feeling is that if
you're out in the world applying deep learning, you can probably find a way to
run some kind of model in the browser.

Furthermore, the kinds of interactions you can get with users by having a
"real-time" inference model are wildly different than from a slow web-request
model, or an unknown amount of time if queues are involved. Notably, this kind
of real-time interaction allowed me, previously, to build an interactive
fashion design booth, where the audience could engage with a GAN, and also an
interactive [dance booth](https://github.com/silky/dance-booth), where people
go to dance with an AI.

<center>
![](/images/blog/dance-booth-fashion-designer.png)
</center>

We were able to put together both of these projects much faster, and much more
portably, because we were using JavaScript-based deep learning inference.

So I encourage you to take a look at
[TensorFlow.js](https://js.tensorflow.org/), and try and build something with
it!

