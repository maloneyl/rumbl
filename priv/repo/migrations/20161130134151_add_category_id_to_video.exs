defmodule Rumbl.Repo.Migrations.AddCategoryIdToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :category_id, references(:categories)
      # on_delete: nilify_all could be a good option in this use case
    end
  end
end
