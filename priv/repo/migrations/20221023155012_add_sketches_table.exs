defmodule Showoff.Repo.Migrations.AddSketchesTable do
  use Ecto.Migration

  def up do
    execute "CREATE TABLE sketches(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      room_id INTEGER NOT NULL,
      svg text NOT NULL,
      source text NOT NULL,
      FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE
    )"
  end

  def down do
    execute "DROP TABLE sketches"
  end
end
