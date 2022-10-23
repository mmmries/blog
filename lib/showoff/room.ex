defmodule Showoff.Room do
  use Ecto.Schema

  schema "rooms" do
    field(:name, :string)

    has_many(:sketches, Showoff.Sketch)
  end
end
