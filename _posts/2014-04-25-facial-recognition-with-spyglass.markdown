---
title = "Facial Recognition With Spyglass"
tags = ["ruby", "opencv", "spyglass", "friendly-bot"]
---

The first step in working towards [Friendly Bot](/blog/2014/04/23/planning-friendly-bot) is to get some code working that can capture an image from a webcam and detect a face in it.
I knew that [OpenCV](http://opencv.org/) had facilities for doing facial recognition, but I was hoping to avoid some of the documentation pain that I have heard about from other people.
I did a quick search for rubygems that wrapped opencv and found [spyglass](https://github.com/andremedeiros/spyglass) by [André Medeiros](https://twitter.com/superdealloc).

Spyglass makes a serious attempt to simplify the OpenCV API and so far it looks very promising. There is even [a great example of doing facial recognition](https://github.com/andremedeiros/spyglass/blob/master/examples/cascade_classifier.rb) that got me started almost immediately.

<!--more-->

## Setup

Before I could install spyglass I needed to install OpenCV.
> $ brew install opencv

The OpenCV classifier needs an xml document that tells it what features to look for. Luckily a bunch of examples come installed with OpenCV.
> $ ls /usr/local/Cellar/opencv/2.4.8.2/share/OpenCV/haarcascades/

```
haarcascade_eye.xml
haarcascade_eye_tree_eyeglasses.xml
haarcascade_frontalface_alt.xml
haarcascade_frontalface_alt2.xml
haarcascade_frontalface_alt_tree.xml
haarcascade_frontalface_default.xml
...
```

Now I installed spyglass and made one slight adaptation to the example provided in the gem.

```ruby
require 'bundler/setup'
require 'spyglass'
require './lib/face_picker'

include Spyglass 

classifier  = CascadeClassifier.new("./haarcascade_frontalface_default.xml")
window      = GUI::Window.new "Video"
cap         = VideoCapture.new 0
frame       = Image.new

loop do
  cap >> frame

  rects = classifier.detect(frame, scale_factor: 1.5, min_size: Size.new(30, 30))
  rect = rects.sort_by(&:area).last # pick the biggest face found
  frame.draw_rectangle(rect, Color.new(255, 0, 0)) if rect

  window.show(frame)

  break if GUI::wait_key(100) > 0
end
```

Basically I wanted to avoid having multiple faces in the image so I did a quick "pick the biggest one" and drew a box around it in the frame.

## Wait, is it seriously that easy?

Yes.

<iframe width="640" height="480" src="//www.youtube.com/embed/FATO0nC8SnY" frameborder="0" allowfullscreen></iframe>

## [Friendly Bot](/blog/2014/04/23/planning-friendly-bot) Milestones

1. ~~Write some code that can detect a face in an image~~
2. Write some artoo code that can control a servo
3. Make a webcam mount with servos for pan and tilt
4. Write some artoo code that controls the roomba
5. Load code onto the Beagle Bone Black that controls the roomba and servos
6. Load code onto the Beagle Bone Black that can detect faces seen by the webcam
7. Write some glue code on the Beagle Bone Black that turns the roomba and servos to keep a face in the center of the image
8. Make the roomba wander until it finds a face to follow (first time we can use the title Friendly Bot)
9. Make friendly bot play the "curious" beeps when it finds a face
10. Make Friendly Bot recognize family members and do "happy" or "skeptical" beeps


