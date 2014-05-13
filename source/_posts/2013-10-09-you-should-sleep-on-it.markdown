---
layout: post
title: "you should sleep on it"
date: 2013-10-09 18:23
comments: false
categories: programming
published: false
---

### TL;DR If you are thinking about refactoring something, go sleep before you start.

I was recently watching the [Katrina Owen Play-by-Play](https://peepcode.com/products/play-by-play-kytrinyx) video and had an interesting experience.

<!--more-->

I watched the first half of the video and had to pause it for a few days. While watching the first half of the video the pacing felt just right. As Katrina was struggling to read through the code and reason about what it was doing I was asking most of the same questions about what was going on. I found myself occasionally rewinding to see the m3u8 file to get the context of what was happening.

A few days later when I picked up where I had left off the pacing of the video felt really slow. I kept feeling impatient because Geoffrey or Katrina would be asking a question that I already knew the answer to. It felt like they were taking a long time to see a refactoring that was staring them in the face.

What had changed between watching the first half and watching the second half? __Time and sleep.__

## Indexed Mental Model

When I was reading the code and thinking about the problem for the first time, I was right there with Katrina. I was stumbling on the same things she was stumbling on. When I came back a few days later my brain had finished its background indexing. My mental model was clear.

I had this lingering feeling of deja vu after I realized that time and sleep had made the problem simple. Eventually I realized that it felt very similar to the difference between writing code at work and writing code at home.

## Sad Code

When I first got hired to write ruby code full time I was surprised at how little I liked it.  When I had learned ruby on my own my code always felt amazing. Every library I wrote looked way better than the code I was writing at work. I argued endlessly with my boss about why we needed to use ruby. Eventually my boss caved in and let me do a new prototype in ruby.

I went to work and it really did take less time than it would have taken me in PHP. When the code was done I had this terrible sinking feeling in my stomache.  My code had gotten done fast, but it wasn't pretty. It didn't make me happy like my code at home. The project was a resounding success, but I wasn't excited about it.

What went wrong? My ruby code was beautiful at home, but it was ugly at work. Why can't I love my code a work the way I love my code at home?

## Zen and the Art of Coding

[Typing is not the bottleneck.](http://anarchycreek.com/2009/05/26/how-tdd-and-pairing-increase-production/) Scoping, commiting, tests, etc are not bottlenecks either. They might be bottlenecks for getting code to work, but they are not bottlenecks for getting beautiful code.  If you want code to be beautiful you will probably run into two major bottlenecks: __naming and abstracting__.

There are no simple techniques for finding the right name or picking the right abstractions. It takes time and thought. Usually at work a feature needs to be done right now. It is hard to explain why we should spend more time on a library that is already working. In addition to the urgency at work, you need to write code for several hours in a row. You don't take breaks for days at a time or sleep between commits. So usually your first idea about how something should be abstracted ends up being written into the code.

At home I tend to write code in 1 hour sprints. Now that I have kids these 1 hour sprints are usually separated by 2 days. This means that when I come back to work on something I have lots of new ideas about abstractions and names. It takes a lot longer on the calendar to get a feature out, but I fall in love with that code.

## How do you Write Beautiful Code at Work?

The drive to get things done quickly will always conflict with the desire to make beautiful code. Urgent feature requests will almost never get the "beautiful code treatment" that a side project will get.  But not everything I do at work is an urgent feature.

### Out-of-band Work

I have lots of little tools for infrastructure or simplifying common tasks. Sometimes I can actually convince my boss that it is worth the companies time and money to refactor before adding new features. For these projects I try to spend time on them same way I spend time on my side projects. Spend 30 min a day on these out-of-band projects. You won't be able to release as often, but those 30 min will be packed with good ideas.

### End of the Day Wrap-up

Sometimes I get to the end of a project 15 or 30 min before I am going to leave work. It is very easy to waste this time by checking my email one more time or finding some mundane task.  I can also use this time to read over a problematic piece of code. Remember that class you had to edit today that was 500 lines long? Or that feature that took twice as long as you thought because it depends on some ball-of-mud legacy code?

Take the last 10 minutes of the day to read this code and then go home and sleep on it. The next morning you will have lots of ideas about how to improve that code.

## This Post Needs to End

You can get faster at writing code.

Your team can get faster at releasing features.

Your brain is not going to get much faster at being brilliant.

If you want brilliant code, take your time and sleep on it.
