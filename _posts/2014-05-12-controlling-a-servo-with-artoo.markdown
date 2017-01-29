---
layout: post
title: "Controlling a Servo with Artoo"
date: 2014-05-12 21:51:15 -0600
comments: true
tags: ruby artoo friendly-bot digispark
---

Now that I have [some basic facial recognition](/blog/2014/04/25/facial-recognition-with-spyglass/) working we need to be able to control the direction of the camera. The first step to do this is to get some wires connected from my laptop to a servo and send signals that control the motion of the servo.

# Ingredients

[Artoo.io](http://artoo.io/documentation/drivers/servo/) has a really simple interface for handling gpio like servos. In my case I used a [digispark](http://digistump.com/products/1) to get access to some gpio pins that my laptop can control. Eventually I will use the [Beagle Bone Black](http://beagleboard.org/Products/BeagleBone+Black) to control the servos, but the digispark gives me an easy way to test this out for just $9.

<!--more-->

# Preparation

First I had to solder the headers to the digispark when it arrived. This always stresses me out because I am not very good at soldering and I worry about getting the embedded components too hot and frying the chip before I even use it. I really wish companies would offer an option to buy the hardware pre-soldered for an extra couple of dollars. An hour later it was soldered and didn't look broken.

According to [the artoo docs](http://artoo.io/documentation/platforms/digispark/#HowToConnect) we need to run two commands in order to get our connection to the digispark working. First we need to run a command that uploads a new firmware to the digispark. Let's give it a whirl:

```
$ artoo littlewire upload
         run  /Users/michael/.rvm/gems/ruby-2.1.0/.artoo/commands/littlewireLoader_v13 from "."
/Users/michael/.rvm/gems/ruby-2.1.0/.artoo/commands/littlewireLoader_v13: /Users/michael/.rvm/gems/ruby-2.1.0/.artoo/commands/littlewireLoader_v13: cannot execute binary file
```

Well that didn't work. Let's at least try to scan the usb devices to figure out the vendor and product ID that we need in to configure out artoo code.

```
$ artoo scan usb
OS not yet supported...
```

At this point you may be feeling like a sad panda, but there is always another way. I booted my laptop to ubuntu from a live  USB drive and tried installing the artoo gem again. I don't know anyone from the [Hybrid Group](http://hybridgroup.com/), but I heard [Ron Evans](https://twitter.com/deadprogram) on the [Ruby Rogues](http://rubyrogues.com/) and he sounded like the kind of person that runs a linux distro so I was hoping that the gems would run more smoothly on ubuntu.

Sure enough once ruby was running and the gems were installed the two commands ran fine and I was read to test.

# The Dish

Now we are ready to write some code that changes the position of the servo. This turns out to be trivial. I used a couple of standard bread-board type wires to connect the servo's ground, 5v and signal wires to the ground, 5v and pin1 pins on the digispark and fired up this code (this code runs both on Ubuntu and OSX).

```ruby
require 'artoo'
connection :digispark, :adaptor => :littlewire, :vendor => 0x1781, :product => 0x0c9f
device :board, :driver => :device_info
device :servo, :driver => :servo, :pin => 1, :range => {:min => 0, :max => 180} # pin must be a PWM pin

i = 0

work do
  puts "Firmware name: #{board.firmware_name}"
  puts "Firmata version: #{board.version}"

  every(1) do
    servo.move(i % 180)
    puts "Current position: #{servo.current_angle}"
    i += 1
  end
end
```

And this is what happened!

<iframe width="640" height="360" src="//www.youtube.com/embed/ISK5bVShs2w" frameborder="0" allowfullscreen></iframe>

## [Friendly Bot](/blog/2014/04/23/planning-friendly-bot) Milestones

1. ~~Write some code that can detect a face in an image~~
2. ~~Write some artoo code that can control a servo~~
3. Make a webcam mount with servos for pan and tilt
4. Write some artoo code that controls the roomba
5. Load code onto the Beagle Bone Black that controls the roomba and servos
6. Load code onto the Beagle Bone Black that can detect faces seen by the webcam
7. Write some glue code on the Beagle Bone Black that turns the roomba and servos to keep a face in the center of the image
8. Make the roomba wander until it finds a face to follow (first time we can use the title Friendly Bot)
9. Make friendly bot play the "curious" beeps when it finds a face
10. Make Friendly Bot recognize family members and do "happy" or "skeptical" beeps
