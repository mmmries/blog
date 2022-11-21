defmodule BlogWeb.HomepageTest do
  use BlogWeb.ConnCase

  test "it renders successfully", %{conn: conn} do
    conn = get(conn, ~p(/))

    assert html_response(conn, 200) =~ "Build Your Own Blinky"
  end

  # TODO: find a way to test the LiveSearch component which is mounted into the statically rendered homepage
  # test "searching for blog posts", %{conn: conn} do
  #   assert {:ok, view, _html} = get(conn, ~p(/)) |> live()
  #   # => {:error, :nosession}
  #
  #   html =
  #     view
  #     |> element("form.global-search")
  #     |> render_change(%{search: "water"})
  #
  #   IO.inspect(html)
  # end
end
