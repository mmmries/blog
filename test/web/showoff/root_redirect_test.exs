defmodule BlogWeb.RootRedirectTest do
  use BlogWeb.ConnCase, async: true

  test "it redirects to a random room" do
    {:error, {:redirect, %{to: path}}} = conn() |> live(~p(/))
    assert path =~ ~r(\A/rooms/[0-9A-F]{12}\z)
  end

  def conn do
    %Plug.Conn{build_conn() | host: "showoff.riesd.com"}
  end
end
