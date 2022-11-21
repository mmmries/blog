defmodule BlogWeb.SketchesComponent do
  use BlogWeb, :html

  def list(assigns) do
    ~H"""
      <div id="sketches" class="flex flex-row items-center flex-wrap">
        <%= for sketch_id <- @sketch_ids do %>
          <div class="w-28 h-28 m-2 p-1 gb" phx-click="example" phx-value-id={sketch_id}>
            <img src={~p"/img/#{@room_name}/#{sketch_id}"} />
          </div>
        <% end %>
      </div>
    """
  end
end
