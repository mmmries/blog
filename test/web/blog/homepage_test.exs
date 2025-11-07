defmodule BlogWeb.HomepageTest do
  use BlogWeb.ConnCase

  test "it renders successfully", %{conn: conn} do
    conn = get(conn, ~p(/))

    assert html_response(conn, 200) =~ "Build Your Own Blinky"
  end

  test "homepage contains search functionality", %{conn: conn} do
    conn = get(conn, ~p(/))
    html = html_response(conn, 200)
    
    # Should have search input with our new placeholder
    assert html =~ "Search posts..."
    # Should have the search icon
    assert html =~ "viewBox=\"0 0 24 24\""
  end

  # Note: Testing the LiveView search component directly on the homepage is complex
  # because it's mounted in a statically rendered page without a LiveView session.
  # See search_live_test.exs for comprehensive search functionality tests.
end
