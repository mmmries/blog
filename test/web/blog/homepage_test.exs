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

    # Test searching for content
    view
    |> form("form", search: "elixir")
    |> render_change()

    # Should have search results
    assert has_element?(view, "a[href*='/']")

    # Test clearing search
    view
    |> form("form", search: "")
    |> render_change()

    # Results should be cleared
    refute has_element?(view, ".absolute.top-full")
  end

  test "search blur functionality works", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p(/))

    # Search for something first
    view
    |> form("form#search", search: "elixir")
    |> render_change()

    # Should have results - check for the search results dropdown specifically
    assert has_element?(view, "#search-results")

    # Trigger blur event
    view
    |> element("input")
    |> render_blur()

    # Results should be cleared after the delay - check the dropdown is gone
    refute has_element?(view, "#search-results")
  end
end
