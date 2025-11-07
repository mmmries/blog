defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view

  def mount(%{"year" => year, "month" => month, "day" => day, "slug" => slug}, _session, socket) do
    with {:ok, date} <- date(year, month, day),
         slug <- trim_slug(slug),
         {:ok, post} <- Blog.get_post(date, slug) do
      socket =
        socket
        |> assign(:post, post)

      {:ok, socket}
    else
      _ ->
        socket = put_flash(socket, :error, "Couldn't find post")
        {:ok, redirect(socket, to: "/")}
    end
  end

  defp date(year, month, day) do
    [year, month, day] |> Enum.join("-") |> Date.from_iso8601()
  end

  defp trim_slug(slug) do
    String.trim_trailing(slug, ".html")
  end
end
