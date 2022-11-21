defmodule Showoff.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Showoff.Repo

      import Ecto
      import Ecto.Query
    end
  end

  setup _tags do
    %{} = Showoff.Repo.query!("DELETE FROM rooms", [])
    %{} = Showoff.Repo.query!("DELETE FROM sketches", [])
    :ok
  end
end
