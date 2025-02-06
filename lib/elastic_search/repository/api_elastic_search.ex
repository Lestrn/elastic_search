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

  def maybe_create_index() do
    case Tesla.head(client(), "/#{@index_name}") do
      {:ok, %Tesla.Env{status: 200}} ->
        IO.puts("Index #{@index_name} already exists. Skipping creation.")

      {:ok, %Tesla.Env{status: 404}} ->
        IO.puts("Index #{@index_name} does not exist. Creating...")

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

        Tesla.put(client(), "/#{@index_name}", articles)

      {:error, reason} ->
        IO.puts("Error checking index existence: #{inspect(reason)}")
    end
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

  def create_field_elastic_search(id, attrs) do
    Tesla.post(client(), "#{@index_name}/_doc/#{id}", attrs |> Jason.encode!())
  end

  def update_field_elastic_search(id, attrs) do
    request_body = [
      %{
        doc: attrs
      }
      |> Jason.encode!()
    ]

    Tesla.post(client(), "#{@index_name}/_update/#{id}", request_body)
  end

  def delete_field_elastic_search(id) do
    Tesla.delete(client(), "#{@index_name}/_doc/#{id}")
  end
end
