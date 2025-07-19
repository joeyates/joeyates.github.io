defmodule Blog.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:tailwind, "~> 0.2.0"},
      {:fermo, "0.19.0", override: true},
      {:payloadcms_graphql_client, "~> 0.1.8"},
      {:datocms_graphql_client, "0.17.0"},
      {:fermo_datocms_graphql_client, "0.17.0"},
      {:fermo_helpers, "~> 0.12.0"}
    ]
  end
end
