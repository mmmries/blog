defmodule BlogWeb.PageController do
  use BlogWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def post(conn, %{"year" => year, "month" => month, "day" => day, "slug" => slug}) do
    with {:ok, date} <- date(year, month, day),
          slug <- trim_slug(slug),
         {:ok, post} <- Blog.get_post(date, slug)
    do
     render(conn, "post.html", post: post)
    else
      _ -> raise Phoenix.Router.NoRouteError, conn: conn, router: BlogWeb.Router
    end
  end

  defp date(year, month, day) do
    [year, month, day] |> Enum.join("-") |> Date.from_iso8601()
  end

  defp trim_slug(slug) do
    String.trim_trailing(slug, ".html")
  end
end
