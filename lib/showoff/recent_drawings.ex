defmodule Showoff.RecentDrawings do
  alias Showoff.Drawing

  @doc "this function opens the DETS table used to store drawings, it should be called when the application starts"
  def init do
    filename = Application.app_dir(:blog)
               |> Path.join("priv/drawings/recent.dets")
               |> String.to_charlist()
    {:ok, _table_name} = :dets.open_file(Showoff.RecentDrawings, file: filename)
  end

  def add_drawing(%Drawing{}=drawing) do
    id = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    true = :dets.insert_new(__MODULE__, {id, drawing})
    publish_updated_list()
  end

  def list do
    :dets.match(__MODULE__, :"$1")
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn([{_id, drawing}]) -> drawing end)
  end

  defp publish_updated_list do
    BlogWeb.Endpoint.broadcast(
      "recent_drawings",
      "update",
      %{recent: list()}
    )
  end
end
