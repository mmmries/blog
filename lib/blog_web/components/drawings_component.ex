defmodule BlogWeb.DrawingsComponent do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
      <div class="row">
        <%= for drawing <- @drawings do %>
          <div class="example" phx-click="example" phx-value-text={drawing.text} phx-value-id={drawing.id}>
            <%= {:safe, drawing.svg} %>
          </div>
        <% end %>
      </div>
    """
  end
end
