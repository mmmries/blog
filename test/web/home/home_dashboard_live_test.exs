defmodule BlogWeb.HomeDashboardLiveTest do
  use BlogWeb.ConnCase

  test "Gives no access initially" do
    {:ok, view, _html} = conn() |> live(~p(/home))

    html =
      view
      |> element("#no-access")
      |> render()

    assert html =~ "<h1 id=\"no-access\">No Access!</h1>"
  end

  test "Authenticated Users can get access" do
    {:ok, view, _html} =
      conn()
      |> init_test_session(%{current_user: "user@example.com"})
      |> live(~p(/home))

    html =
      view
      |> element("#access")
      |> render()

    assert html =~ "<h1 id=\"access\">Access!</h1>"
  end

  test "Authenticated Users that we don't know about get no access" do
    {:ok, view, _html} =
      conn()
      |> init_test_session(%{current_user: "other_user@example.com"})
      |> live(~p(/home))

    html =
      view
      |> element("#no-access")
      |> render()

    assert html =~ "<h1 id=\"no-access\">No Access!</h1>"
  end

  def conn do
    %Plug.Conn{build_conn() | host: "home.riesd.com"}
  end
end
