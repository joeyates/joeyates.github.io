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
      # Page generation
      {:fermo, "0.19.2", override: true},
      {:fermo_helpers, "~> 0.12.0"},
      # Assets
      {:esbuild, "~> 0.7.0"},
      {:tailwind, "~> 0.2.0"},
      # CMS
      {:payloadcms_graphql_client, "~> 0.1.9"},
      # Code quality
      {:green, "~> 0.1.4", only: [:dev]}
    ]
  end
end
