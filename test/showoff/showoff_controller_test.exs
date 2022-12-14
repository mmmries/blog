defmodule Showoff.ShowoffControllerTest do
  use BlogWeb.ConnCase

  test "it renders example images" do
    conn = get(conn(), ~p(/img/_ex/circle))

    {:ok, drawing} = Showoff.Examples.get("circle")
    assert conn.status == 200
    assert response_content_type(conn, :svg) == "image/svg+xml; charset=utf-8"
    assert conn.resp_body == drawing.svg
  end

  def conn do
    %Plug.Conn{build_conn() | host: "showoff.riesd.com"}
  end
end
