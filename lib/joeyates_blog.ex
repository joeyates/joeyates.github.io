defmodule JoeyatesBlog do
  @moduledoc """
  Documentation for `JoeyatesBlog`.
  """

  use Fermo, %{
    base_url: Application.fetch_env!(:fermo, :base_url),
    i18n: [:en],
    localized_paths: true,
    exclude: ["templates/*", "layouts/*", "javascripts/*", "stylesheets/*"]
  }
  import Fermo, only: [page: 4]

  use Helpers

  def config do
    DatoCMS.GraphQLClient.configure()

    config = initial_config()

    config = page(
      config,
      "/templates/home.html.slim",
      "/index.html",
      %{id: "home", locale: :en}
    )

    {:ok, config}
  end
end
