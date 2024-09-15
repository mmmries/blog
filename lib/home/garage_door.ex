defmodule Home.GarageDoor do
  def get_status do
    with {:ok, message} <- Gnat.request(:gnat, "home.garage_door", "get_status") do
      {:garage_door_status, message.body}
    end
  end

  def toggle do
    Gnat.pub(:gnat, "home.garage_door", "toggle")
  end
end
