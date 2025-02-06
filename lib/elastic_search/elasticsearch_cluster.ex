defmodule ElasticSearch.ElasticsearchCluster do
  use Elasticsearch.Cluster, otp_app: :elastic_search

  def start_link(_) do
    Elasticsearch.Cluster.start_link(__MODULE__)
  end
end
