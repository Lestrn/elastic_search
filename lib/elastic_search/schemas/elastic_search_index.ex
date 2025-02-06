defmodule ElasticSearch.Schemas.ElasticSearchIndex do
  alias Elasticsearch.Index
  alias Elasticsearch

  @index_name "article_index"

  def create_index() do
    articles = %{
      mappings: %{
        properties: %{
          author_name: %{type: "text", analyzer: "english"},
          status: %{type: "boolean"},
          tags: %{type: "text", analyzer: "english"},
          label: %{type: "text", analyzer: "english"},
          inserted_at: %{type: "date"},
          updated_at: %{type: "date"},
        }
      }
    }

    Index.create(MySuperApp.ElasticsearchCluster, @index_name, articles)
  end

  def update() do
   
  end
end
