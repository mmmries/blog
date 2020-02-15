---
title = "Functional Programming Adoption"
tags = ["functional", "adoption"]
---

__TL/DR; looking at global averages may not be a very good way to make decisions about programming__

I was thinking about my recent experience with Elixir and how it models certain domains in a more natural way than Ruby.
This led to production systems that I found to me more stable, maintainable and debuggable than the ruby equivalents.
I'm always happy to find new tools and new ways of solving problems, but it leaves one big question unanswered.

> Why aren't more companies using functional programming for these types of problems?

Generally speaking if you look at language popularity as measured by things like [the stack overflow developer survey](https://insights.stackoverflow.com/survey/2017#technology-programming-languages), the [tiobe index](https://www.tiobe.com/tiobe-index/) or the [githut metrics about github](http://githut.info/) you have to look pretty far down to see the first functional language entries.

## Rationalizations

I've heard comments in both the Ruby and Elixir communities along the lines of, "it only takes 3 ruby engineers to do the work of 10 java engineers, so there are fewer total jobs".
I also hear comments in these smaller language communities about how engineers love their jobs so much that they switch less often.
Both of these arguments sound to me like rationalizations about the data.

If I had told you that there was a tool that gave you a 300% benefit for your bottom-line, would you predict that there would be less job postings for people familiar with those tools?
If there were really a 300% benefit from using Ruby or Elixir, wouldn't market forces drive up the adoption and replace lots of java engineers?

## Moar Data

![moar input](https://i.imgur.com/8bY9Q2t.gif)

One common way of measuring adoption in companies is to count the number of job postings that mention a particular language.
So I grabbed a few languages/tools and searched indeed.com and stackoverflow for job postings. I used the same search terms for each (you can see [the raw data here](https://gist.github.com/mmmries/3162c3e7ff6d7628390def3bdfc21cda#file-language_job_postings-csv)).
Breaking the data down into buckets of functional languages, object-oriented languages and languages that do both (scala and javascript) looks like this:

![job postings chart](/assets/images/2018-03-18/job_postings_by_language_type.png)

The data from indeed.com seems to mirror the language popularity indexes, but the stackoverflow job postings look quite different.
The stackoverflow jobs seem to show that nearly half of all job postings have some relation to functional programming.

So why the big difference in these two data sets?
The most obvious difference would seem to be the audience of the two different tools.
Which of the two would you be more likely to use?
Which of them would your company be more likely to post a job on?

## Conclusion

Perhaps it doesn't matter how much of the entire world uses a given tool.
If the people and companies that you want to work with are making good use of a tool, that's good enough feedback to take a closer look at your own use-case and consider whether that tool applies.

Nearly the entire software world spent decades creating software with a [waterfall approach](https://en.wikipedia.org/wiki/Waterfall_model).
What percentage of all programming jobs still look more like waterfall than [the agile manifesto](http://agilemanifesto.org/)?
If the whole world of programming can make those mistakes, then that world may not inform your engineering decisions very well.