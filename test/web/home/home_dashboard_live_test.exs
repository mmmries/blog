defmodule BlogWeb.HomeDashboardLiveTest do
  use BlogWeb.ConnCase

  test "Gives no access initially" do
    {:ok, view, _html} = conn() |> live(~p(/home))

    assert has_element?(view, "#no-access")
    refute has_element?(view, "#garage-door")
  end

  test "Authenticated Users can get access" do
    {:ok, view, _html} =
      conn()
      |> init_test_session(%{current_user: "user@example.com"})
      |> live(~p(/home))

    refute has_element?(view, "#no-access")
    assert has_element?(view, "#garage-door")
  end

  test "Authenticated Users that we don't know about get no access" do
    {:ok, view, _html} =
      conn()
      |> init_test_session(%{current_user: "other_user@example.com"})
      |> live(~p(/home))

    assert has_element?(view, "#no-access")
    refute has_element?(view, "#garage-door")
  end

  def conn do
    %Plug.Conn{build_conn() | host: "home.riesd.com"}
  end
end
