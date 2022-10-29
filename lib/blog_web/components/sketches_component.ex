defmodule BlogWeb.SketchesComponent do
  use Phoenix.Component
  alias BlogWeb.Router.Helpers, as: Routes

  def list(assigns) do
    ~H"""
      <div class="flex flex-row items-center flex-wrap">
        <%= for sketch_id <- @sketch_ids do %>
          <div class="w-28 h-28 m-2 p-1 gb" phx-click="example" phx-value-id={sketch_id}>
            <img src={Routes.showoff_path(@socket, :img, @room_name, sketch_id)} />
          </div>
        <% end %>
      </div>
    """
  end
end
