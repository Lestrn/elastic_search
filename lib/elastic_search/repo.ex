defmodule ElasticSearch.Repo do
  use Ecto.Repo,
    otp_app: :elastic_search,
    adapter: Ecto.Adapters.Postgres
end
