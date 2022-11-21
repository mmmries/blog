defmodule Showoff.Examples do
  @list [
    {"circle", "' You can draw simple shapes like a circle\n\ncircle"},
    {"notes", "' These lines that start with a ' are just notes\n' They don't draw anything, it's just for people to read.\n\ntriangle\n' Author: Archie"},
    {"attrs1","' You can change how the computer draws the shape by adding attributes\n' The square below has been set to salmon\n' Try changing it to `square fill=red`\n' Did it change color? Try some other colors...\n\nsquare fill=salmon"},
    {"attrs2","' There are other attributes you can set too.\n' `stroke=blue` tells the computer draw the outline with a blue color.\n\nsquare fill=lightskyblue stroke=darkblue"},
    {"pos","' You can also change where the computer draws your shape.\n' Basic shapes start at `cx=50 cy=50`\n' Try changing the `cx` and `cy`.\n\nhexagon fill=turquoise cx=50 cy=50"},
    {"coords1","' The left side of your paper is `cx=0` and the right side is `cx=100`\n' Can you move the shape below to the left and right sides?\n' What happens if you draw the shape off the edge of your paper?\n\noctagon fill=green cx=25 cy=50"},
    {"coords2","' The top of your paper is `cy=0` and the bottom is `cy=100`\n' Can you make the triangle below just barely touch the top and bottom?\n\ntriangle fill=lightgreen stroke=darkgreen cy=50"},
    {"size","' Now, let's change the size of a shape.\n' Try changing the `r` (radius) of the shapes below\n\nhexagon cx=25 cy=25 fill=springgreen r=20\noctagon cx=75 cy=75 fill=coral r=13"},
    {"q2","' Quiz: What is the biggest circle you can fit on your paper?\n\ncircle fill=yellow stroke=orange r=5"},
    {"clip", "'Can you guess how a clipPath works?\n'Hint: it controls where the 'paint' is put down for items that have a \"clip-path\" attribute\n\nclipPath id=bottom\n  rect x=0 y=52.5 width=100 height=47.5\n\nclipPath id=top\n  rect x=0 y=0 width=100 height=47.5\n\ncircle fill=black r=28\ncircle fill=red r=30 clip-path=url(#top) stroke=black\ncircle fill=white r=30 clip-path=url(#bottom) stroke=black\n\n'Fill in some lines on the insides of the half-circles\npath stroke=black d=\"M19.6 52.5 L80.4 52.5\"\npath stroke=black d=\"M19.6 47.75 L80.4 47.75\"\n' make the inner circles\ncircle fill=black r=12\ncircle fill=white r=8\ncircle fill=white r=5 stroke=black\n"},
    {"share","' Now it's your turn. Try drawing some shapes and then hit the `Share` button so your classmates can see\n\nsquare r=75 fill=skyblue\ncircle r=60 fill=lightseagreen stroke=darkgreen cy=110 cx=80\ncircle r=40 fill=lightseagreen stroke=darkgreen cy=110 cx=10\ncircle r=30 fill=lightseagreen stroke=darkgreen cy=110 cx=40\ncircle r=15 fill=yellow cx=20 cy=20"}
  ]

  @drawings Enum.map(@list, fn({id, text}) ->
    {:ok, svg} = Showoff.kid_text_to_svg(text)
    %Showoff.Drawing{id: id, text: text, svg: svg}
  end)

  def list do
    @drawings
  end
end
