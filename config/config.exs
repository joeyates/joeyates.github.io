import Config

config :slime, :keep_lines, true
config :yamerl, node_mods: []

config :fermo,
  base_url: System.fetch_env!("BASE_URL"),
  assets: [Fermo.Assets.ESBuild, Fermo.Assets.Tailwind]

config :esbuild,
  version: "0.16.4",
  default: [
    args:
      ~w(priv/source/javascripts/application.js --bundle --target=es2017 --outdir=build/assets --external:/fonts/* --external:/images/*),
    env: %{"NODE_PATH" => Path.expand("deps", __DIR__)}
  ]

config :tailwind,
  version: "4.0.9",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=priv/source/stylesheets/app.css
      --output=build/assets/app.css
    )
  ]

case config_env() do
  :dev ->
    Application.put_env(
      :fermo,
      :live_asset_pipelines,
      esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
      tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
    )

    live_reload_js = """
    window.addEventListener("message", event => {
      if (event.data?.type === "payload-document-event") {
        console.debug("Blog live reload: Received payload-document-event, rebuilding page", event)
        window.fermoLiveSocket.rebuild()
      }
    })
    """

    config :fermo, live_reload_js: live_reload_js

  _ ->
    nil
end
