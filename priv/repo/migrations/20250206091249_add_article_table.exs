defmodule ElasticSearch.Repo.Migrations.AddArticleTable do
  use Ecto.Migration

  def change do
    create table(:article) do
      add :author_name, :string
      add :status , :boolean
      add :tags, :string
      add :label, :string
      timestamps(type: :utc_datetime)
    end
  end
end
