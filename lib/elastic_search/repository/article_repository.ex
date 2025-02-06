defmodule ElasticSearch.Repository.ArticleRepository do
  alias ElasticSearch.Schemas.Article
  alias ElasticSearch.Repo

  def fetch_articles() do
    Repo.all(Article)
  end

  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs, true)
    |> Repo.insert()
  end
end
