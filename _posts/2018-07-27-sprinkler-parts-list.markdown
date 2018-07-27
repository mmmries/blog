---
layout: post
title: "Sprinkler Project Parts List"
date: 2018-07-27 10:49:00 -0600
comments: false
tags: elixir nerves sprinkler meetup
---

The [nerves remote meetup](/2018/07/03/nerves-sprinkler-meetup.html) is getting started soon and it seemed like a good idea to get a parts list put together.
This should work for anyone following along with the meetup or for people watching the recording later.

* [8 Channel Relays](http://a.co/033ga9I) these will send power to the sprinkler valves
* [Raspberry Pi 3 B+](http://a.co/1xSC2kR) this will be running our nerves code
* [3 Pack of Micro SD Cards](http://a.co/5miyrEc) holds our nerves code
* [Wires and Breadboard](http://a.co/bCkOvnf) useful for quickly wiring things together in a testable way
* [Wall Plug to USB](http://a.co/3l4Mpkx)
* [USB to MicroUSB cords](http://a.co/3Dz5VYo)
* [USB <-> TTL Serial Cable](http://a.co/0oimg8b) (optional) useful to debug what's happening on the raspberry pi

> Note: if you have micro SD cards, micro USB charge cords etc laying around, you can probably just use what you have.

For this project we are planning to re-use most of the existing wiring that your sprinkler control board has avaiable.
Here is a picture of my sprinkler control board.

![sprinkler control board](/assets/images/2018-07-27/sprinkler_control_board.jpg)

The main 24VAC power line comes into the top-left and I plan to just tap into those in order to power the relays.
The small boxes in the middle are the power inputs for each of the valves so I plan to wire my relays to those same inputs.
