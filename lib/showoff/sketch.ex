defmodule Showoff.Sketch do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "sketches" do
    field(:source, :string)
    field(:svg, :string)

    belongs_to(:room, Showoff.Room)
  end

  def changeset(sketch \\ %Sketch{}, params) do
    cast(sketch, params, [:room_id, :source, :svg])
    |> validate_required([:room_id, :source, :svg])
    |> validate_length(:source, min: 3, max: 10_000)
    |> validate_length(:svg, min: 3, max: 10_000)
  end
end
