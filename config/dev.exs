import Config

alias DatoCMS.GraphQLClient.Backends.StandardClient

Application.put_env(
  :fermo,
  :live_asset_pipelines,
  [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]
)

Application.put_env(
  :fermo,
  :live_mode_servers,
  [{Registry, keys: :unique, name: :datocms_live_update_query_registry}]
)

config = Application.get_env(:datocms_graphql_client, :config, [])
merged = Keyword.merge(
  config,
  backend: StandardClient,
  endpoint: "https://graphql-listen.datocms.com/preview",
  live: true
)

config :datocms_graphql_client, :config, merged
