---
title: Scholarships for August Technical Deep Learning Workshop Close on Sunday!
author: Noon van der Silk
image: /images/blog/scholarship-vid.jpg
date: 2019-07-24
preview: Our first scholarship round closes on the 28th of July. Still a few spots left!
tags: announcement
vimeo: https://player.vimeo.com/video/349597581
vimeoTitle: Note on scholarships.
---

Ruth and I are very pleased to be offering scholarships for our workshop
coming up on the 8th of August. We've already accept first-round scholarships
(6 people), and so there are some remaining places.

We're encouraging applications from anyone that has typically faced barriers
in their career/learning in the tech industry. One of our big aims at
Braneshop is to increase the representation in the AI industry, and this is
one way we're working towards that goal.

You can find the application form here: [Scholarship for the 6 Week Technical
Deep Learning Workshop](https://noonvandersilk.typeform.com/to/Tnfm4a), and of
course more details about the workshop itself here: [6 Week
Workshop](/6-week-workshop-on-deep-learning.html).

We've also got a scholarship for the [AI For Leadership
Workshop](/ai-for-leadership.html), coming up in September. This is an
important one for us as well, as, in order to see change broadly through-out
the industry, we will need change in leadership positions.

Here at the Braneshop we're creating a welcoming and supportive community for
everyone to be involved in AI. We hope you join us!

<!--more-->

#### Technical details about the video ...

I had a lot of fun making the video above. You'll notice, if you watch it,
that my person is cut out, and a new weird background is inserted. I did this
using [deep-lab](https://github.com/tensorflow/models/tree/master/research/deeplab)
from TensorFlow. If you're feeling adventurous you can try out their demo for
yourself, on [Google Colab](https://colab.sandbox.google.com/github/tensorflow/models/blob/master/research/deeplab/deeplab_demo.ipynb).

With that in hand, I worked out how to extract all the frames of the video as
individual images, then ran that network over each of them (there were ~1600
images, but it only took a few minutes on my laptop (which doesn't have a
GPU)). After that, I made the little background animation[^2], overlayed the
images, and stitched them back together. I did all this using the
"[ffmpeg](https://ffmpeg.org/)" and [ImageMagick](https://imagemagick.org/index.php)[^1].

Also, while looking around and eventually settling on deep-lab, I found a
[TensorFlow.js](https://www.tensorflow.org/js) [demo
project](https://github.com/tensorflow/tfjs-models/tree/master/body-pix) that
performs [person-segmentation in the
browser](https://storage.googleapis.com/tfjs-models/demos/body-pix/index.html)!
It's not amazingly high quality, but it runs in the browser! Pretty cool.


[^1]: Roughly, here are the commands I used (ignoring the ones I used to generate the animations):
<pre class="terminal">
# Extract images
ffmpeg -i original.mp4 images/img%05d.jpg -hide_banner
#
# In the "vid-bg" folder; make composite images.
for i in *.png; do convert $i ~/dev/deep-lab/masked-images/img$i \
      -gravity center -compose over -composite ~/dev/deep-lab/with-bg/$i.jpg; \
done;
#
# Learn the framerate of the original video
ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate \
        original.mp4
#
# Make a video from images
ffmpeg -framerate 29.5 -pattern_type glob -i 'images/*.jpg' \
       -c:v libx264 -pix_fmt yuv420p out.mp4
#
# Copy audio into a video, from a video (named here "audio.mp4")
ffmpeg -i video.mp4 -i audio.mp4 -c copy -map 0:0 -map 1:1 -shortest out.mp4
</pre>


[^2]: I used my "[cppn-cli](https://github.com/silky/cppn-cli)" program to do
this.
<pre class="terminal">
# Having a pre-existing checkpoint
cppn existing sample --checkpoint_dir logs/cf9ecd76 --width 288 --height 513 \
     --out out/vid-bg --z_steps 1614
</pre>
