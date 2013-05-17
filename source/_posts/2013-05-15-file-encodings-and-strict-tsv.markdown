---
layout: post
title: "file encodings and strict tsv"
date: 2013-05-15 10:19
comments: true
categories: programming ruby tab-separated
---

One of the things I deal with at work is receiving batch files from vendors. We usually ask the vendors to send us data in tab-separated format. [Tab-separated formatting](http://www.iana.org/assignments/media-types/text/tab-separated-values) is an extremely simple format that gets around problems of escaping characters by simply disallowing tabs inside of a column.

Initially I was using the [CSV](http://www.ruby-doc.org/stdlib-2.0/libdoc/csv/rdoc/CSV.html) ruby standard library to handle the parsing of these files, but CSV is a much more complicated format that allows quoting columns and escape sequences.  This more complicated handling can cause havoc if a vendor is using the simple/strict version of the tab-separated standard.

I asked [James Edward Gray II](https://twitter.com/JEG2) if there was a way to invoke the CSV library without the extra handling and he responsed with a super simple tab-separated value parser.

<blockquote class="twitter-tweet" data-conversation="none"><p>@<a href="https://twitter.com/hqmq_">hqmq_</a>open(“…”) do |f|headers = f.gets.split(“\t”)f.each do |row|fields = Hash[headers.zip(f.gets.split(“\t”)]# …endend</p>&mdash; James Edward Gray II (@JEG2) <a href="https://twitter.com/JEG2/status/327448417058033664">April 25, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

James' solution is beautifully simple, but it doesn't quite meet all of my requirements.

* streaming (don't read the whole file into memory)
* transparently use DOS-MAC-UNIX line-endings
* support UTF-8 encoding (I might need to support other encodings later)

Jame's solution does read line-by-line, but File#gets does not support different line endings. So after playing around with a few options I wrote a simple class that would worry about reading line-by-line with whatever line-endings they might find.

<script src="https://gist.github.com/hqmq/5596989.js?file=line_reader.v1.rb"></script>

This solution is very similar to James' solution except that it adds a step of reading the file in chunks and then searching the chunks for newlines using a regex. Next I need to take these lines and split them on the tabs.

<script src="https://gist.github.com/hqmq/5596989.js?file=strict_tsv.rb"></script>

By now i have introduced a small and difficult to find bug. Everything looks very normal, and I was relying on ruby's default UTF-8 support, but it turns out that File#read has a strange behavior. Some of the lines that come back from the LineReader were encoded as UTF-8, but others would come back with a ASCII-8BIT encoding. The string contains the same binary data in either case, but when it is marked with an ASCII-8BIT encoding some of its data is now invalid ASCII characters. So things like JSON.generate will now blow up in your face.  The errors I encountered were very far away in my codebase because nothing blew up until I tried to use the string for some sort of normal operation.

So why does File#read sometimes mark the string as ASCII-8BIT. Well since I am reading the file in byte-size chunks I might be reading in data without getting to the end of a multi-byte sequence. That sort of makes sense to me, but it was very surprising behavior.  So the fix that I found was to initialize a string that is already marked with a UTF-8 encoding and then use File#read(size,buffer) to copy data into the existing string. Since I am going to search the string for special line-ending characters anyway I really don't care if the buffer contains a partial UTF-8 character.

<script src="https://gist.github.com/hqmq/5596989.js?file=line_reader.v2.rb"></script>

So once again a very simple idea has somehow become a gem. The gem hasn't been published yet since I am assuming that I will still run into a few more bugs, but if you ever needed to parse tab-separated data in ruby it will probably be more work than you are planning on.
