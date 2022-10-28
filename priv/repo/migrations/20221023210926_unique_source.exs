defmodule Showoff.Repo.Migrations.UniqueSource do
  use Ecto.Migration

  def up do
    execute "CREATE UNIQUE INDEX sketch_source ON sketches (room_id, source)"
  end

  def down do
    execute "DROP INDEX sketch_source"
  end
end
