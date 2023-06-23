defmodule JoeyatesBlog.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :joeyates_blog,
      version: "0.1.0",
      elixir: "~> 1.9",
      compilers: Mix.compilers() ++ [:fermo],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:esbuild, :logger]
    ]
  end

  def deps do
    [
      {:esbuild, "~> 0.7.0"},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:fermo, "0.16.7", path: "/home/joe/code/gh/joeyates/fermo", override: true},
      {:datocms_graphql_client, path: "/home/joe/code/gh/joeyates/elixir_datocms_graphql_client", override: true},
      {:fermo_datocms_graphql_client, path: "/home/joe/code/gh/joeyates/fermo_datocms_graphql_client"},
      {:fermo_helpers, "~> 0.12.0"}
    ]
  end
end
