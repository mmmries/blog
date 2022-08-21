---
title = "Using VSCode Remote Containers"
tags = ["book-club","vscode","ml","racket","ruby"]
---

Some friends recently started a sort of book club, by taking the [UofW Programming Languages Course](https://www.coursera.org/learn/programming-languages) on Coursera together.

## Course Structure

The course focuses on learning about programming languages through the lense of 3 very different languages:

* ML
* Racket
* Ruby

The goal of the course is to learn about programming languages in general, but these 3 specific languages are used to get a broad view of different language types.

One of the first things to do in the course is to [install Standard ML](https://www.coursera.org/learn/programming-languages/supplement/mi5oU/part-a-software-installation-and-use-sml-and-emacs).
Anytime I see installation instructions that take multiple pages, I get nervous that I'll end up with some weird problem that will eat up time and reduce my motivation to learn the material.

So I decided to try out [VSCode Remote Containers](https://code.visualstudio.com/docs/remote/containers) which lets you work on code that is running inside of a container.

## How To

Instead of following 2 pages of instructions, just make a new directory and open that directory in VSCode. Now do the following:

* Install the "Remote - Containers" extension in VSCode
* Create a `.devcontainer` directory
* Create a `devcontainer.json` file in that directory with the following content:

```json
{
  "image": "ynishi/docker-sml:latest",
  "forwardPorts": [],
  "customizations": {
    // Configure properties specific to VS Code.
    "vscode": {
      // Add the IDs of extensions you want installed when the container is created.
      "extensions": []
    }
  }
}
```

* Now click the Remote Explorer button in the left-side of VSCode
* Click the "+" button next to "Containers"
* Click "Open current folder in Container"

You'll see a little modal showing the progress as it pulls down the image, and installs some extra code inside of the container. Then VSCode will refresh and you now have a terminal inside the container.

Open your terminal and type `sml`, you'll get the standard ML prompt and any code you start writing in VSCode will be in the current working directory of your terminal running inside the container.