defmodule BlogWeb.ShowoffLiveTest do
  use BlogWeb.ConnCase

  test "shows examples" do
    {:ok, view, _html} = conn() |> live(~p(/rooms/test))

    view
    |> element("#examples div[phx-value-id=circle]")
    |> render_click()

    html =
      view
      |> element("#screen")
      |> render()

    assert html ==
             "<div class=\"screen\" id=\"screen\"><svg viewbox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle r=\"25\" cx=\"50\" cy=\"50\" fill=\"black\"></circle></svg></div>"

    html =
      view
      |> element("[name=drawing_text]")
      |> render()

    assert html =~ "You can draw simple shapes like a circle"
  end

  test "drawing and sharing a shape" do
    {:ok, view, _html} = conn() |> live(~p(/rooms/test))

    html =
      view
      |> element("form")
      |> render_change(%{"drawing_text" => "circle fill=blue"})

    assert [{"div", _attrs, [{"svg", attrs, svg}]}] = Floki.find(html, "#screen")
    assert attrs == [{"viewbox", "0 0 100 100"}, {"xmlns", "http://www.w3.org/2000/svg"}]
    assert svg == [{"circle",[{"r", "25"},{"cx", "50"},{"cy", "50"},{"fill", "blue"}],[]}]

    view
    |> element("form")
    |> render_submit()

    # wait for the PubSub message to be published/received
    :timer.sleep(20)

    html = render(view)
    assert [sketch] = Floki.find(html, "div#sketches div")
    assert [id] = Floki.attribute(sketch, "phx-value-id")
    assert sketch = Showoff.RecentDrawings.get("test", String.to_integer(id))
    assert sketch.source == "circle fill=blue"
  end

  def conn do
    %Plug.Conn{build_conn() | host: "showoff.riesd.com"}
  end
end
