defmodule BlogWeb.SketchesComponent do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
      <div class="flex flex-row items-center flex-wrap">
        <%= for sketch <- @sketches do %>
          <div class="w-28 h-28 m-2 p-1 gb" phx-click="example" phx-value-text={sketch.source} phx-value-id={sketch.id}>
            <%= {:safe, sketch.svg} %>
          </div>
        <% end %>
      </div>
    """
  end
end
