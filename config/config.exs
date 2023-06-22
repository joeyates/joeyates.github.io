import Config

config :slime, :keep_lines, true
config :yamerl, node_mods: []

config :datocms_graphql_client, :config,
  api_key: System.fetch_env!("DATOCMS_API_KEY"),
  backend: DatoCMS.GraphQLClient.Backends.MemoizingClient

config :fermo, :base_url, System.fetch_env!("BASE_URL")

config :fermo, :assets, Assets.ESBuild

config :esbuild,
  version: "0.16.4",
  default: [
    args:
      ~w(priv/source/javascripts/application.js --bundle --target=es2017 --outdir=build/assets --external:/fonts/* --external:/images/*),
    env: %{"NODE_PATH" => Path.expand("deps", __DIR__)}
  ]

environment_config = "#{Mix.env()}.exs"

if File.regular?(Path.join("config", environment_config)) do
  import_config environment_config
end
