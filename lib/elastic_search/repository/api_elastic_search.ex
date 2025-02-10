defmodule ElasticSearch.Repository.ApiElasticSearch do
  alias ElasticSearch.Repository.ArticleRepository
  use Tesla

  @index_name "article_index"

  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://localhost:9200/"},
      {Tesla.Middleware.Headers,
       [{"content-type", "application/json"}, {"X-elastic-product", "Elasticsearch"}]}
    ])
  end

  def maybe_create_index(index \\ @index_name) do
    case Tesla.head(client(), "/#{index}") do
      {:ok, %Tesla.Env{status: 200}} ->
        IO.puts("Index #{index} already exists. Skipping creation.")

      {:ok, %Tesla.Env{status: 404}} ->
        IO.puts("Index #{index} does not exist. Creating...")

        articles =
          %{
            mappings: %{
              properties: %{
                author_name: %{type: "text", analyzer: "english"},
                status: %{type: "boolean"},
                tags: %{type: "text", analyzer: "english"},
                label: %{type: "text", analyzer: "english"},
                inserted_at: %{type: "date"},
                updated_at: %{type: "date"}
              }
            }
          }
          |> Jason.encode!()

        Tesla.put(client(), "/#{index}", articles)

      {:error, reason} ->
        IO.puts("Error checking index existence: #{inspect(reason)}")
    end
  end

  def bulk_index_articles(index \\ @index_name) do
    bulk_data =
      ArticleRepository.fetch_articles()
      |> Enum.map(fn article ->
        [
          %{"index" => %{"_index" => index, "_id" => article.id}},
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

    Tesla.post(client(), "#{index}/_bulk", bulk_data)
  end

  def clear_elastic_search(index \\ @index_name) do
    Tesla.delete(client(), index)
  end

  def create_field_elastic_search(id, attrs, index \\ @index_name) do
    Tesla.post(client(), "#{index}/_doc/#{id}", attrs |> Jason.encode!())
  end

  def update_field_elastic_search(id, attrs, index \\ @index_name) do
    request_body = [
      %{
        doc: attrs
      }
      |> Jason.encode!()
    ]

    Tesla.post(client(), "#{index}/_update/#{id}", request_body)
  end

  def delete_field_elastic_search(id, index \\ @index_name) do
    Tesla.delete(client(), "#{index}/_doc/#{id}")
  end

  def search(author_name, tags, index \\ @index_name) do
    with {:ok, response} <-
           Tesla.get(client(), "#{index}/_search?q=tags:#{URI.encode(tags)}+AND+author_name:#{URI.encode(author_name)}"),
         {:ok, %{"hits" => %{"hits" => results}}} <- Jason.decode(response.body) do
      Enum.map(results, fn %{"_id" => id} -> id end)
    else
      _ -> []
    end
  end

  def get_article_by_id_elastic_search(id, index \\ @index_name) do
    with {:ok, response} <- Tesla.get(client(), "#{index}/_doc/#{id}") do
        Jason.decode(response.body)
    else
      _ -> {:error, :not_found}
    end
  end
end
