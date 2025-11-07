defmodule BlogWeb.SearchLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders search input" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    assert has_element?(view, "input[placeholder='Search posts...']")
    assert has_element?(view, "svg")  # search icon
  end

  test "shows no results initially" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    refute has_element?(view, "a[href*='/']")  # no post links
  end

  test "searches for posts and displays results" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    # Search for "elixir" which should return some results
    view
    |> form("form", search: "elixir")
    |> render_change()
    
    # Should have results now
    assert has_element?(view, "a[href*='/']")  # post links should appear
    
    # Check that results contain proper structure
    html = render(view)
    assert html =~ "Elixir" || html =~ "elixir"
  end

  test "searches for specific term and displays expected results" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    # Search for "sprinkler" which should return specific results
    view
    |> form("form", search: "sprinkler")
    |> render_change()
    
    html = render(view)
    
    # Should have sprinkler-related posts
    assert html =~ "Sprinkler" || html =~ "sprinkler"
    assert has_element?(view, "a[href*='sprinkler']")
  end

  test "clears results when search is empty" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    # First search for something
    view
    |> form("form", search: "elixir")
    |> render_change()
    
    assert has_element?(view, "a[href*='/']")
    
    # Then clear the search
    view
    |> form("form", search: "")
    |> render_change()
    
    # Should have no results
    refute has_element?(view, "a[href*='/']")
  end

  test "deactivates search results on blur" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    # Search for something first
    view
    |> form("form", search: "elixir")
    |> render_change()
    
    assert has_element?(view, "a[href*='/']")
    
    # Trigger blur event
    view
    |> element("input")
    |> render_blur()
    
    # Wait for the delayed turn_off message
    :timer.sleep(600)
    
    # Results should be cleared after the delay
    refute has_element?(view, "a[href*='/']")
  end

  test "post links have correct structure" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    view
    |> form("form", search: "elixir")
    |> render_change()
    
    html = render(view)
    
    # Check for the structure we expect from modern_post_link
    # Should have post titles and dates
    assert html =~ ~r/\w+\s+\d{1,2},\s+\d{4}/  # Date format like "March 18, 2018"
  end

  test "handles no search results gracefully" do
    {:ok, view, _html} = live_isolated(build_conn(), BlogWeb.SearchLive)
    
    # Search for something that shouldn't exist
    # Use a single character which won't create any meaningful trigrams
    view
    |> form("form", search: "q")
    |> render_change()
    
    # Should have no results but not crash
    refute has_element?(view, "a[href*='/']")
  end
end