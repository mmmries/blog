defmodule BlogWeb.HomepageTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  test "it renders successfully", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p(/))

    assert html =~ "Build Your Own Blinky"
  end

  test "homepage contains search functionality", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p(/))

    # Should have search input with our placeholder
    assert has_element?(view, "input[placeholder='Search posts...']")
    # Should have the search icon
    assert has_element?(view, "svg")
  end

  test "search functionality works end-to-end", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p(/))

    refute has_element?(view, "#search-results")

    # Test searching for content
    view
    |> form("form", search: "elixir")
    |> render_change()

    # Should have search results
    assert has_element?(view, "#search-results")
    assert has_element?(view, "#search-results a[href*='/']")

    # Test clearing search
    view
    |> form("form", search: "")
    |> render_change()

    # Results should be cleared
    refute has_element?(view, "#search-results")
  end
end
