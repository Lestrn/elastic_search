# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elastic_search,
  ecto_repos: [ElasticSearch.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :elastic_search, ElasticSearchWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ElasticSearchWeb.ErrorHTML, json: ElasticSearchWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ElasticSearch.PubSub,
  live_view: [signing_salt: "w4LDgmSn"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :elastic_search, ElasticSearch.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
moon_config_path = "#{File.cwd!()}/deps/moon/config/surface.exs"

if File.exists?("#{moon_config_path}") do
  import_config(moon_config_path)
end

config :surface, :components, [
  # put here your app configs for surface
]

config :esbuild,
  version: "0.17.11",
  elastic_search: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  elastic_search: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
