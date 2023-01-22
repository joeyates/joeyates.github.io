defmodule JoeyatesBlog.CMS do
  @moduledoc false

  alias Fermo.DatoCMS.GraphQLClient

  def setup do
    DatoCMS.GraphQLClient.configure()
  end

  def home(for_path) do
    result = GraphQLClient.query_for_path!(
      for_path,
      """
      query MyQuery {
        home {
          title
          abstract
        }
      }
      """,
      %{}
    )

    result.home
  end

  def by_creation_date(collection) do
    collection
    |> Enum.sort(
      fn x, y ->
        case DateTime.compare(y.created_at, x.created_at) do
          :gt -> true
          :lt -> false
        end
      end)
  end
end
