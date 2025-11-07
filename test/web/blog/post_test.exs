defmodule BlogWeb.PostTest do
  use BlogWeb.ConnCase

  test "it renders a post successfully", %{conn: conn} do
    {:ok, post} = Blog.get_post(~D{2020-02-18}, "full-text-search-in-memory")
    conn = get(conn, post.path)

    assert html_response(conn, 200) =~ "Full Text Search In Memory"
  end

  test "it handles invalid post routes", %{conn: conn} do
    conn = get(conn, ~p(/2030/01/01/nonexistent))
    assert conn.assigns.flash == %{"error" => "Couldn't find post"}
    assert html_response(conn, 302) =~ "redirected"
  end
end
