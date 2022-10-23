defmodule Showoff.Repo.Migrations.UniqueRoomNames do
  use Ecto.Migration

  def up do
    execute "CREATE UNIQUE INDEX rooms_name ON rooms (name)"
  end

  def down do
    execute "DROP INDEX rooms_name"
  end
end
