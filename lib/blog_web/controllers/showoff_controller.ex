defmodule BlogWeb.ShowoffController do
  use BlogWeb, :controller

  def index(conn, _params) do
    random_room_name = :crypto.strong_rand_bytes(6) |> Base.encode16()
    redirect(conn, to: "/rooms/#{random_room_name}")
  end
end
