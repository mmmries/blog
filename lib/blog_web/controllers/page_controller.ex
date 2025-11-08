defmodule BlogWeb.PageController do
  use BlogWeb, :controller

  def privacy(conn, _param) do
    render(conn, "privacy.html")
  end

  def terms(conn, _param) do
    render(conn, "terms.html")
  end
end
