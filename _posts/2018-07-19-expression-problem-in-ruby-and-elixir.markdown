---
layout: post
title: "The Expression Problem in Ruby and Elixir"
date: 2018-07-19 08:09:00 -0600
comments: false
tags: elixir ruby expression-problem
---

> TL/DR; If you want to get a quick overview of the expression problem and how it is addressed in Elixir you can [check out this presentation](https://youtu.be/sJvfCE6PFxY) by Kevin Rockwood.
If you want to see some suggestions for Ruby you can [watch this presentation](https://youtu.be/eyDaemttTgc) by Mike Burns.

A little while ago my co-founder at Spiff, Jeron Paul, was talking to me about functional programming vs object-oriented programming.
He told me about an idea that you could represent a program in two dimensions of data types and behavior.
Slicing one direction would be easier with functional programming and slicing the other would be easier with object-oriented programming.
I hadn't heard this concept before and started looking into why that might be the case.

## The Expression Problem

I came across [The Expression Problem](https://en.wikipedia.org/wiki/Expression_problem).
The basic idea is that if you need to add a new type of data to a system, it should require the minimum change to the existing functions.
If you want to add a new function, it should require the minimum change to the existing data types.
We can think of this as a subset of [Dave Thomas'](https://pragdave.me/blog/) general idea on good software design.

> A good design is easier to change than a bad design ~ [Dave Thomas at GOTO conf 2015](https://youtu.be/a-BOSpxYJ9M)

As a software system changes we often need to account for new types of data that we weren't previously dealing with.
Maybe we start tracking quotas for sales people in addition to tracking their commissions.
We also need to add new types of functionality to our system.
If you want to learn more about the Expression Problem I really enjoyed [Eli Bendersky's blog post](https://eli.thegreenplace.net/2016/the-expression-problem-and-its-solutions/) which covers many attempts that various languages have made to address this problem.
Eli also wrote [two](https://eli.thegreenplace.net/2018/more-thoughts-on-the-expression-problem-in-haskell/) followup [posts](https://eli.thegreenplace.net/2018/the-expression-problem-in-go/) that touch on Haskell and Go in particular.

As we go through some approaches keep in mind that the cost of changing existing code can vary depending on whether that code is in your project, or is pulled in as part of a library, or perhaps it is maintined by another team at your company.
Your project might want to optimize for adding behavior to the existing types of data provided by an open source library.
Or you might be better off optimizing for the ability to add new types that you can pass in to an open source library that handles some work for you.

## An Example

For the purpose of illustration I'll re-use [Mike Burns'](https://robots.thoughtbot.com/authors/mike-burns) example from his [ruby meetup presention](https://youtu.be/eyDaemttTgc).
The basic idea is to start with some code that can pretty-print addition operations.
Then we extend it to handle negations (a new data type) and evaluating the additions (a new function).

```ruby
Literal.new(3).show                           # => "3"
Add.new(Literal.new(5), Liternal.new(4)).show # => "5 + 4"
Add.new(
  Add.new(Literal.new(1), Literal.new(2)),
  Literal.new(3)
).show                                        # => "1 + 2 + 3"
```

## Object-Oriented vs Functional

Ruby is an extremely flexible language, and as you might expect, there are many ways to address this problem in Ruby.
You should really just go watch [Mike Burns presention](https://youtu.be/eyDaemttTgc), but I'll briefly mention a few methods he covers here.

__Just Add More Classes/Methods__

Perhaps the most obvious way of extending the program is to just add a new class for new data types and add new methods for new behaviors.
So to add a `Negation` we would write

```ruby
class Negation < Struct.new(:expression)
  def show
    "-(#{expression.show})"
  end
end

Negation.new(Literal.new(4)).show                          # => -(4)
Negation.new(Add.new(Literal.new(1), Literal.new(2))).show # => -(1 + 2)
```

Adding new types is really easy.
But if we want to add the ability to evaluate an expression, we are forced to go back and modify our definitions for `Literal` and `Add`.

```ruby
class Literal < Struct.new(:number)
  ...
  def eval
    number
  end
end

class Add < Struct.new(:left, :right)
  ...
  def eval
    left.eval + right.eval
  end
end
Add.new(Literal.new(1), Literal.new(2)).eval # => 3
```

This is where the idea that object-oriented programming naturally slices one direction on the dimensions of data types and behaviors comes from.
Adding new types in this style is easy and adding new behaviors or functions is hard.

__"Functional" Modules__

The main idea here is to separate the behavior from the data.
Instead of having `Literal#show` and `Add#show` methods, we make a separate module with a method that implements both of those two behaviors.

```ruby
module Expression
  def self.show(expression)
    if expression.is_a?(Literal)
      expression.number.to_s
    elsif expression.is_a?(Add)
      "#{show(expression.left)} + #{show(expression.right)}"
    end
  end
end

Expression.show(Add.new(Literal.new(1), Liternal.new(2))) # => "1 + 2"
```

Now if we want to add support for `Negation` we have to go back and modify all behaviors that might accept the new type.

```ruby
Negation = Struct.new(:expression)
module Expression
  def self.show(expression)
    ...
    elsif expression.is_a?(Negation)
      "-(#{show(expression.expression)})"
    end
  end
end

Expression.show(Negation.new(Literal.new(1))) # => -(1)
```

To add support for a new behavior we can write:

```ruby
module Expression
  def self.eval(expression)
    if expression.is_a?(Literal)
      expression.number
    elsif expression.is?(Add)
      eval(expression.left) + eval(expression.right)
    end
  end
end
```

This is a very functional style of ruby.
Your team might call this "service objects" and build them a little differently, but the hallmark of this style is you end up with conditionals in the behavior code.
Because the behavior is separated from the data type, you have to check which type it is before you take action.

This functional approach swaps our tradeoffs.
It is easy to add a new behavior, but adding a new type requires us to go back and modify our behavior code.
This is the basis of the idea that functional programming slices one direction and object-oriented code slices the other.

## It Depends...

Of course, things are actually a bit more nuanced than just OO vs FP.
In ruby you could use Monkey Patching to modify the behavior of an existing type.
This makes it easier to introduce new behavior without having to change the original file that defined a class, but comes with its own tradeoffs of brittleness and cognitive load.
I've seen teams use wrapper objects that provide some extra behavior, but delegate anything else back to the original object.
This alleviates the brittleness of Monkey Patching, but the developers have to figure out whether something has already been wrapped or not later on.

Mike Burns also touches on using "Visitor Pattern", "Inheritance", "Runtime Mixins" and "Object Algebras" as other ways of optimizing for changing in one way or other.
Each of these techniques trade ease of change (at least certain types of changes) against additional indirection and complexity in the underlying code.

## Naive Elixir

The most obvious implementation for this problem in an FP language looks a bit like the "functional modules" approach from above.

```elixir
defmodule Literal do
  defstruct [:number]
end

defmodule Add do
  defstruct [:left, :right]
end

defmodule Printer do
  def show(%Literal{number: num}), do: "#{num}"
  def show(%Add{left: left, right: right}), do: "#{show(left)} + #{show(right)}"
end
expression = %Add{
  left: %Literal{number: 1},
  right: %Literal{number: 2}
}
Printer.show(expression) # => "1 + 2"
```

Adding the `Negation` type requires us to change the behavior code

```elixir
defmodule Negation do
  defstruct [:expression]
end

defmodule Printer do
  ...
  def show(%Negation{expression: expression}), do: "-#{show(expression)}"
end

expression = %Negation{
  expression: %Add{
    left: %Literal{number: 1},
    right: %Literal{number: 2}
  }
}
Printer.show(expression) # => "-(1 + 2)"
```

And adding new behavior is predictably easy

```elixir
defmodule Evaluator do
  def eval(%Literal{number: num}), do: num
  def eval(%Add{left: left, right: right}), do: eval(left) + eval(right)
end

expression = %Add{
  left: %Literal{number: 1},
  right: %Literal{number: 2}
}
Evaluator.eval(expression) # => 3
```

## Protocols

This problem has been talked about for a long time and as third-party open-source packages became more important to getting work done, some languages have looked for novel approaches to it.
Elixir was inspired [by clojure's protocols](https://clojure.org/reference/protocols) which allow for adding implementation code without modifying the original implementation code.
Using [Elixir's Protocols](https://elixir-lang.org/getting-started/protocols.html) we could start our math code like this:

```elixir
defmodule Literal do
  defstruct [:number]
end

defmodule Add do
  defstruct [:left, :right]
end

defprotocol Printer do
  def show(expression)
end

defimpl Printer, for: Literal do
  def show(%Literal{number: number}), do: "#{number}"
end

defimpl Printer, for: Add do
  def show(%Add{left: left, right: right}) do
    "#{Printer.show(left)} + #{Printer.show(right)}"
  end
end

expression = %Add{
  left: %Literal{number: 1},
  right: %Literal{number: 2}
}
Printer.show(expression) # => 1 + 2
```

Adding a type previously required us to change the `Printer.show` function, but now we can just add the implementation for our one new type in its our own code.

```elixir
defmodule Negation do
  defstruct [:expression]

  defimpl Printer do
    def show(%Negation{expression: expression}) do
      "-(#{Printer.show(expression)})"
    end
  end
end

expression = %Negation{
  expression: %Add{
    left: %Literal{number: 1},
    right: %Literal{number: 2}
  }
}
Printer.show(expression) # => -(1 + 2)
```

Adding new behavior is just as easy as it was before:

```elixir
defprotocol Evaluator do
  def eval(expression)
end

defimpl Evaluator, for: Literal do
  def eval(%Literal{number: number}), do: number
end

defimpl Evaluator, for: Add do
  def eval(%Add{left: left, right: right}) do
    Evaluator.eval(left) + Evaluator.eval(right)
  end
end

expression = %Add{
  left: %Literal{number: 1},
  right: %Literal{number: 2}
}
Evaluator.eval(expression) # => 3
```

Using protocols requires a little extra setup and it reduces cohesion of the code a bit because your implementations of `Printer.show` are now in multiple different places.
For this reason, I generally see Elixir codebases using plain functions and data structures most of the time.
But if you are writing an open-source library where the user might want to pass their own data structures into your library, you have the option of defining a protocol and allowing your users to add the implementation that they need. You can also define [typespecs](https://elixir-lang.org/getting-started/typespecs-and-behaviours.html) with your protocols and [dialyzer](http://erlang.org/doc/man/dialyzer.html) can tell users of your library if they are returning the wrong type of data from their implementation.

> I made [a little repo](https://github.com/mmmries/expression_problem) to explore these ideas and it has handy diff links if you want to see more detail.

## Conclusions

Writing software that can be changed is a hard problem.
Knowing which types of changes are most likely and most expensive can help quite a lot.
Learning about the Expression Problem gives me another lens that I can use to predict which changes are likely and expensive.
It even gives me tools I can use to optimize for the likely changes in my project.
