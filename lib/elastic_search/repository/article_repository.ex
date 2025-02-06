defmodule ElasticSearch.Repository.ArticleRepository do
  alias ElasticSearch.Schemas.Article
  alias ElasticSearch.Repo
  alias ElasticSearch.Repository.ApiElasticSearch

  def fetch_articles() do
    Repo.all(Article)
  end

  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs, true)
    |> Repo.insert()
  end

  def update_article(article_id, attrs) do
    case Repo.get(Article, article_id) do
      nil ->
        {:error, :not_found}

      article ->
        changeset =
          article
          |> Article.changeset(attrs, true)

        with {:ok, result} <- Repo.update(changeset) do
          ApiElasticSearch.update_field_elastic_search(
            article_id,
            changeset.changes |> Map.put(:updated_at, result.updated_at)
          )

          result
        end
    end
  end

  def delete_article(article_id) do
    case Repo.get(Article, article_id) do
      nil ->
        {:error, :not_found}

      article ->
        with {:ok, result} <- Repo.delete(article) do
          ApiElasticSearch.delete_field_elastic_search(article_id)
          result
        end
    end
  end
end
