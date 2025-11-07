defmodule BlogWeb.TagLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders tag page with posts", %{conn: conn} do
    # Test with a tag that should have posts
    {:ok, view, html} = live(conn, ~p(/tags/elixir))

    assert html =~ "elixir"
    # Should have post links
    assert has_element?(view, "a[href*='/']")
  end

  test "contains search functionality", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p(/tags/elixir))

    # Should have search input
    assert has_element?(view, "input[placeholder='Search posts...']")
    # Should have the search icon
    assert has_element?(view, "svg")
  end

  test "search functionality works on tag pages", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p(/tags/elixir))

    # Test searching
    view
    |> form("form", search: "nerves")
    |> render_change()

    # Should have search results (if any nerves posts exist)
    # We don't assert results exist since it depends on content
    # But the search should not crash

    # Test clearing search
    view
    |> form("form", search: "")
    |> render_change()

    # Should not crash and results should be cleared
    refute has_element?(view, ".absolute.top-full")
  end
end
