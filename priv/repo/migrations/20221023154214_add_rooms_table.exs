defmodule Showoff.Repo.Migrations.AddRoomsTable do
  use Ecto.Migration

  def up do
    execute "CREATE TABLE rooms(id INTEGER PRIMARY KEY AUTOINCREMENT, name text)"
  end

  def down do
    execute "DROP TABLE rooms"
  end
end
