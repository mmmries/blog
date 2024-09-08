defmodule Home.GarageDoor do
  def toggle do
    Gnat.pub(:gnat, "home.garage_door", "toggle")
  end
end
