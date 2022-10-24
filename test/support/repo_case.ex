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
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Showoff.Repo)
  end
end
