defmodule BlogWeb.ShowoffController do
  use BlogWeb, :controller

  def index(conn, _params) do
    random_room_name = :crypto.strong_rand_bytes(6) |> Base.encode16()
    redirect(conn, to: "/rooms/#{random_room_name}")
  end

  def img(conn, %{"room_name" => room_name, "id" => id}) do
    case Showoff.RecentDrawings.get(room_name, id) do
      nil -> send_resp(conn, 404, "")

      sketch ->
        conn
        |> put_resp_header("cache-control", "public, max-age=604800")
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(200, sketch.svg)
    end
  end
end
