defmodule ElasticSearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElasticSearchWeb.Telemetry,
      ElasticSearch.Repo,
      {DNSCluster, query: Application.get_env(:elastic_search, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElasticSearch.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElasticSearch.Finch},
      # Start a worker by calling: ElasticSearch.Worker.start_link(arg)
      # {ElasticSearch.Worker, arg},
      # Start to serve requests, typically the last entry
      ElasticSearchWeb.Endpoint,
      #For elastic search
      ElasticSearch.ElasticsearchCluster
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElasticSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElasticSearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
