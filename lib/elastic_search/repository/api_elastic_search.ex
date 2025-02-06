defmodule ElasticSearch.Repository.ApiElasticSearch do
  alias ElasticSearch.Repository.ArticleRepository
  use Tesla

  @index_name "article_index"

  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://localhost:9200/"},
      {Tesla.Middleware.Headers, [{"content-type", "application/json"}, {"X-elastic-product", "Elasticsearch"}]},
    ])
  end

  def bulk_index_articles() do
    bulk_data =
      ArticleRepository.fetch_articles()
      |> Enum.map(fn article ->
        [
          %{"index" => %{"_index" => @index_name, "_id" => article.id}},
          %{
            author_name: article.author_name,
            status: article.status,
            tags: article.tags,
            label: article.label,
            inserted_at: article.inserted_at,
            updated_at: article.updated_at
          }
        ]
      end)
      |> List.flatten()
      |> Enum.map(fn item ->
        Jason.encode!(item)
      end)
      |> Enum.join("\n")
      |> Kernel.<>("\n")

    Tesla.post(client(), "#{@index_name}/_bulk", bulk_data)
  end

  def clear_elastic_search() do
    Tesla.delete(client(), @index_name)
  end
end
