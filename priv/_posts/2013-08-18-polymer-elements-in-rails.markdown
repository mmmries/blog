---
title = "polymer elements in rails"
tags = ["programming", "ruby"]
---

Recently for our [local ruby meetup group](http://utruby.org/#uv.rb) we had a frontend Battle Royale. The idea was to make a simplistic rails app that could serve as a starting point and then implement a frontend in several different ways (ember, angular, etc) so that we can compare the costs and benefits of these different techniques.

We picked a comic book collection as the simplistic app. You can see the [code](https://github.com/urug/comics) on the URUG github account. The [README](https://github.com/urug/comics/blob/master/README.md) contains information on the desired UI.

I wrote up an implementation using [Polymer Elements](http://polymer-project.org) which is basically a way to write custom HTML elements that encapsulate details of javascript, css and html.

<!--more-->

## Where to Start???
I wanted to start with implementing a small but interesting feature of the UI. In the application.html.erb layout there is a little sidebar that shows a list of comic books with a count of how many issues each comic book has. The initial erb looks like this:

```html
  <div class="well sidebar-nav">
    <ul class="nav nav-list">
      <li class="nav-header">Books</li>
      <% Book.all.each do |book| %>
        <li>
          <span class="badge pull-right"><%= book.issues.count %></span>
          <%= link_to book.name, book_path(book)  %>
        </li>
      <% end %>
      <li><%= link_to "New Book", new_book_path, class: "btn"  %></li>
    </ul>
  </div><!--/.well -->
```

This looked to me like a good chance to encapsulate some details. Wouldn't it be awesome if our layout just look like this?
```html
  <div class="row">
    <div class="span9"><comics-book-list></comics-book-list></div>
    <div class="span3"><comcis-sidebar></comics-sidebar></div>
  </div>
```

Lets ignore the details of using a well class and li elements to represent this list.  Let's just think of it as a sidebar element. So what does the definition of a basic sidebar element look like?

```html
  <link rel="import" href="/polymer/polymer-elements/polymer-ajax/polymer-ajax.html" />
  <polymer-element name="comics-sidebar" attributes="">
    <template>
      <link href="/assets/application.css?body=1" media="all" rel="stylesheet" />
      <div class="well sidebar-nav">
        <ul class="nav nav-list">
          <li class="nav-header">Books</li>
          <template repeat="{{books}}">
            <li>
              <span class="badge pull-right">{{issue_count}}</span>
              <a href="/books/{{id}}">{{name}}</a>
            </li>
          </template>
          <li><a href="/books/new" class="btn">New Book</a></li>
        </ul>
      </div>
      <polymer-ajax id="ajax" url="/books.json" handleAs="json" on-polymer-response="receiveAjax" auto></polymer-ajax>
    </template>
    <script>
      Polymer('comics-sidebar', {
        books: null,
        receiveAjax: function(e){
          this.books = e.detail.response;
        }
      });
    </script>
  </polymer-element>
```

