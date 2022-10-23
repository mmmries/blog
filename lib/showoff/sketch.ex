defmodule Showoff.Sketch do
  use Ecto.Schema

  schema "sketch" do
    field :source, :string
    field :svg, :string

    belongs_to :room, Showoff.Room
  end
end
