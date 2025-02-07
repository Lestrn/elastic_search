defmodule ElasticSearch.Repository.ArticleRepository do
  alias ElasticSearch.Schemas.Article
  alias ElasticSearch.Repo
  alias ElasticSearch.Repository.ApiElasticSearch
  import Ecto.Query

  def fetch_articles() do
    Article
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end


  def get_article_by_id(id) do
    Repo.get(Article, id)
  end

  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs, true)
    |> Repo.insert()
    |> case do
      {:ok, article} -> ApiElasticSearch.create_field_elastic_search(article.id, attrs)
      {:error, changeset} -> {:error, changeset}
    end
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

  def fetch_by_search("", "") do
    fetch_articles()
  end

  def fetch_by_search(author_name, tags) do
    tags_query = if tags == "", do: "*", else: "#{tags}"
    author_name_query = if author_name == "", do: "*", else: "#{author_name}"
    ids = ApiElasticSearch.search(author_name_query, tags_query)

    from(a in Article, where: a.id in ^ids)
    |> Repo.all()
  end

end
