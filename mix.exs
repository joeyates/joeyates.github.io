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
      {:fermo, "0.16.2"}  ,
  {:datocms_graphql_client, "~> 0.15.4"},
  {:fermo_datocms_graphql_client, "~> 0.14.3"},
  {:fermo_helpers, "~> 0.12.0"}

    ]
  end
end
