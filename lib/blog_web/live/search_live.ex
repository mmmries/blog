defmodule BlogWeb.SearchLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <form class="global-search" autocomplete="off" phx-change="search">
      <div class="autocomplete">
        <input type="text" name="search" placeholder="search" phx-blur="deactivate" />
        <%= if Enum.count(assigns.matches) > 0 do %>
          <div class="autocomplete-items">
            <%= for post <- assigns.matches do %>
              <%= BlogWeb.PageView.post_link(post) %>
            <% end %>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def mount(_params, _session, socket) do
    socket = socket |> assign(:matches, []) |> assign(:turning_off, false)
    {:ok, socket}
  end

  def handle_event("search", %{"search" => query}, socket) do
    socket = socket |> assign(:matches, Blog.search(query, 5))
    socket = if socket.assigns.turning_off do
      socket |> assign(:turning_off, false)
    else
      socket
    end
    {:noreply, socket}
  end
  def handle_event("deactivate", _params, socket) do
    Process.send_after(self(), :turn_off, 500)
    socket = socket |> assign(:turning_off, true)
    {:noreply, socket}
  end

  def handle_info(:turn_off, socket) do
    socket = if socket.assigns.turning_off do
      socket |> assign(:turning_off, false) |> assign(:matches, [])
    else
      socket
    end
    {:noreply, socket}
  end
end
