defmodule BlogWeb.SearchComponent do
  use BlogWeb, :live_component

  attr :post, Blog.Post, required: true

  def search_result(assigns) do
    ~H"""
    <a
      class="block px-4 py-3 text-decoration-none border-b border-gray-100 last:border-b-0 transition-colors duration-150 ease-in-out hover:bg-gray-50"
      href={@post.path}
    >
      <div class="text-sm font-medium text-gray-900 leading-tight mb-0.5">{@post.title}</div>
      <div class="text-xs text-gray-600 leading-tight">
        {Calendar.strftime(@post.date, "%B %d, %Y")}
      </div>
    </a>
    """
  end

  def render(assigns) do
    ~H"""
    <form
      class="w-full relative"
      id="search"
      autocomplete="off"
      phx-change="search"
      phx-target={@myself}
    >
      <div class="relative w-full">
        <div class="relative flex items-center">
          <svg
            class="absolute left-3 w-5 h-5 text-gray-500 pointer-events-none z-10"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            >
            </path>
          </svg>
          <input
            type="text"
            name="search"
            placeholder="Search posts..."
            phx-target={@myself}
            phx-debounce="200"
            class="w-full py-2.5 pl-11 pr-4 text-sm text-gray-700 bg-white border border-gray-300 rounded-lg shadow-sm transition-all duration-150 ease-in-out focus:outline-none focus:border-blue-600 focus:ring-3 focus:ring-blue-100 placeholder-gray-400"
          />
        </div>
        <%= if Enum.count(@matches) > 0 do %>
          <div
            id="search-results"
            phx-click-away="deactivate"
            phx-target={@myself}
            class="absolute top-full left-0 right-0 z-50 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-96 overflow-y-auto"
          >
            <%= for post <- @matches do %>
              <.search_result post={post} />
            <% end %>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:matches, fn -> [] end)

    {:ok, socket}
  end

  def handle_event("search", %{"search" => query}, socket) do
    socket = socket |> assign(:matches, Blog.SearchServer.query(query))

    {:noreply, socket}
  end

  def handle_event("deactivate", _params, socket) do
    socket = socket |> assign(:matches, [])
    {:noreply, socket}
  end
end
