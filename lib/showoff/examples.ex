defmodule Showoff.Examples do
  @list [
    "' You can draw simple shapes like a circle\n\ncircle",
    "' Any line you add with a ' at the beginning is ignored\n' They are comments that you can leave for other people\n\ntriangle",
    "' You can change how the computer draws the shape by adding attributes\n' The square below is black unless you give it a color\n' Try changing it to `square fill=red`\n' Did it change color? Try some other colors...\n\nsquare fill=gray",
    "' There are other attributes you can set too.\n' Like stroke=blue to make the computer draw the outline in a different color.\n\nsquare fill=cyan stroke=darkblue",
    "' You can also change where the computer draws your shape.\n' Basic shapes start at `cx=50 cy=50`\n' Try changing the `cx` and `cy`.\n\nhexagon fill=turquoise cx=50 cy=50",
    "' The left side of your paper is `cx=0` and the right side is `cx=100`\n' Can you move the shape below to the left and right sides?\n' What happens if you draw the shape off the edge of your paper?\n\noctagon fill=green cx=25 cy=50",
    "' The top of your paper is `cy=0` and the bottom is `cy=100`\n' Can you make the triangle below just barely touch the top and bottom?\n\ntriangle fill=lightgreen stroke=darkgreen cy=50",
    "' Now, let's change the size of a shape.\n' Try changing the `r` (radius) of the shapes below\n\nhexagon cx=25 cy=25 fill=blue r=8\noctagon cx=75 cy=75 fill=orange r=13",
    "' Quiz: What is the biggest circle you can fit on your paper?\n\ncircle fill=yellow stroke=orange r=5",
    "' Now it's your turn. Try drawing some shapes and then hit the `Share` button so your classmates can see\n"
  ]

  def list do
    Enum.map(@list, fn (text) ->
      {:ok, drawing} = Showoff.kid_text_to_drawing(text, "Example")
      drawing
    end)
  end
end
