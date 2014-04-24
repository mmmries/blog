---
layout: post
title: "Planning Friendly Bot"
date: 2014-04-23 21:14:01 -0600
comments: true
categories: robotics artoo opencv beagleboneblack ruby
---

In many ways Robotics was my first tech love. I remember my dad bringing home a broken printer from work and I took it apart and used the parts to make a little machine that had some LED eyes and drove itself forward and backward.  It wasn't really a robot, but it got me so interested in robotics that I started learning to program.

I paid my way through university ([BYU](http://byu.edu/)) by taking web development contracts, but at school I was studying computer engineering so that I could build a robot for my [senior project](https://www.youtube.com/watch?v=p_uHdzVdef4). 

Once I got my first job I spent most of my free time learning more about software. I had a few ambitious ideas about robots, but never seemed to get them off the ground. Now that I have a young son (3yr) I have found my ambition for robotics growing again. It is basically impossible to get a 3yr old excited about a webserver or database.

So I started thinking through all my old ideas and tried to find one that is:

* feasible
* would make a 3yr old excited

I envisioned a robot that

* Would not break immediately upon being touched
* Would not creep people out
* Appears to be interested in human beings

I imagined a small robot with a camera that would wander around until it saw a human face. When it saw the face it would make a few "curious" beeps (inspired by R2D2) and try to drive itself to get a better view of the face. If it recognizes the person it will make some "happy" beeps and follow that persons face for about 30sec. If it doesn't recognize the person it will make some "skeptical" beeps and go back to wandering.

So here are my plans for "Friendly Bot"

* Roomba as the main body + drive platform
* A webcam for vision
* Webcam can pan and tilt via servos (greater range of vision)
* [OpenCV](http://opencv.org/) to do face detection and facial recognition
* [Beagle Bone Black](http://beagleboard.org/Products/BeagleBone+Black) as the onboard computing
* [Artoo.io](http://artoo.io/) to control the servos and roomba

My milestones that I want to hit in the project will be something like

1. Write some code that can detect a face in an image
2. Write some artoo code that can control a servo
3. Make a webcam mount with servos for pan and tilt
4. Write some artoo code that controls the roomba
5. Load code onto the Beagle Bone Black that controls the roomba and servos
6. Load code onto the Beagle Bone Black that can detect faces seen by the webcam
7. Write some glue code on the Beagle Bone Black that turns the roomba and servos to keep a face in the center of the image
8. Make the roomba wander until it finds a face to follow (first time we can use the title Friendly Bot)
9. Make friendly bot play the "curious" beeps when it finds a face
10. Make Friendly Bot recognize family members and do "happy" or "skeptical" beeps
