import Config

config :slime, :keep_lines, true
config :yamerl, node_mods: []

config :fermo, :base_url, System.fetch_env!("BASE_URL")

config :fermo, :assets, [Fermo.Assets.ESBuild, Fermo.Assets.Tailwind]

config :esbuild,
  version: "0.16.4",
  default: [
    args:
      ~w(priv/source/javascripts/application.js --bundle --target=es2017 --outdir=build/assets --external:/fonts/* --external:/images/*),
    env: %{"NODE_PATH" => Path.expand("deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=priv/source/app.css
      --output=build/assets/app.css
    )
  ]

environment_config = "#{Mix.env()}.exs"

if File.regular?(Path.join("config", environment_config)) do
  import_config environment_config
end
