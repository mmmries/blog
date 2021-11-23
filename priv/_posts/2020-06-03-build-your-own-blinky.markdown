---
title = "Build Your Own Blinky"
tags = ["elixir","nerves","led"]
---

For the next [Nerves Remote Meetup](https://nerves.group/) we want to invite you to build a device.
The project we'll be building can be adapted to people brand new to nerves (a couple hours following a walkthrough) or experienced community members wanting to try something new.
Come build a device, [join our slack group](https://join.slack.com/t/nerves-meetup/shared_invite/zt-7b95x0tv-hiM519At5R7ldzHTRq74pQ), ask questions and share what you learn.

## What to Build

The challenge is to build a nerves device that communicates via LED(s).
If you're brand new to Nerves, you could get started with [the blinky project](https://hexdocs.pm/nerves/getting-started.html).
This uses the LEDs that are built into a raspberry pi and blinks a pattern to let the user know that your nerves code is running.

![LED Matrix](/images/2020-06-03/matrix.jpg)

> Photo Credit: https://www.adafruit.com/product/1487

LEDs can also be used in various other forms like [RGB LEDs](https://www.adafruit.com/product/159) which let you change the color and intensity of the light.
There are [strips of LEDs](https://www.adafruit.com/product/285?length=5) and even [LED Matrix](https://www.adafruit.com/product/1487) options.
Some of these options are [flexible](https://www.adafruit.com/product/4245) or offer [tightly packed LEDs](https://www.adafruit.com/product/3649) so you can render images and animations. Some options have [built in sensors](https://www.adafruit.com/product/2738) so you can access LEDs and check sensors with a single peripheral.

![Dense LED Matrix](/images/2020-06-03/dense.png)

> Photo Credit: https://www.adafruit.com/product/3649

This variety of LEDs gives a ton of options about how to communicate with the outside world.
You can blink an LED to get someone's attention, or vary the color and intensity to indicate relative heat or other conditions.
You could monitor your team's slack messages and use [sentiment analysis](https://hex.pm/packages/veritaserum) and then render various emoticons on an LED matrix.

![Sensor Hat with LEDs](/images/2020-06-03/sense_hat.jpg)

> Photo Credit: https://www.adafruit.com/product/2738

## Your Idea, Your Device

With so many options, it might be hard to know where to get started.
If you're not sure, we suggest grabbing a [raspberry pi zero wireless](https://www.sparkfun.com/products/15470) along with a micro SD card and mini USB.
You can even [find starter kits](https://www.sparkfun.com/products/14298) that come with some basics included.
Then follow the [Getting Started](https://hexdocs.pm/nerves/getting-started.html) on the nerves documentation to get the onboard LEDs blinking.
From there you can write elixir code to check any API you're interested in use the onboard LEDs to communicate about that API.

If that project leaves you wanting more, just [jump onto our slack group](https://join.slack.com/t/nerves-meetup/shared_invite/zt-7b95x0tv-hiM519At5R7ldzHTRq74pQ) and ask for help on how to connect additional LEDs or sensors.
You'll find lots of enthusiastic people who can give you pointers on next steps.