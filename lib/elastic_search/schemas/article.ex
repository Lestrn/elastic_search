defmodule ElasticSearch.Schemas.Article do
    @moduledoc false

    use Ecto.Schema
    import Ecto.Changeset

    schema "article" do
      field :author_name, :string
      field :status, :boolean
      field :tags, :string
      field :label, :string
      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(article, attrs, validate?) do
       maybe_validate(validate?, article, attrs)
    end

    defp maybe_validate(true, article, attrs) do
      article
      |> cast(attrs, [:author_name, :status, :tags, :label])
      |> validate_required([:author_name, :status, :tags, :label])
    end

    defp maybe_validate(false, article, attrs) do
      article
    end
end
