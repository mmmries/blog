defmodule BlogWeb.DrawingsComponent do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
    <div id="examples" class="flex flex-row items-center flex-wrap">
      <%= for drawing <- @drawings do %>
        <div
          class="w-28 h-28 m-2 p-1 gb"
          phx-click="example"
          phx-value-text={drawing.text}
          phx-value-id={drawing.id}
        >
          <%= {:safe, drawing.svg} %>
        </div>
      <% end %>
    </div>
    """
  end
end
