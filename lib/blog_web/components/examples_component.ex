defmodule BlogWeb.ExamplesComponent do
  use BlogWeb, :html

  def list(assigns) do
    ~H"""
    <div id="examples" class="flex flex-row items-center flex-wrap">
      <%= for example_id <- Showoff.Examples.ids() do %>
        <div class="w-28 h-28 m-2 p-1 gb" phx-click="example" phx-value-id={example_id}>
          <img src={~p"/img/_ex/#{example_id}"} />
        </div>
      <% end %>
    </div>
    """
  end
end
