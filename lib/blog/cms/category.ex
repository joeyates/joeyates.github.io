defmodule Blog.CMS.Category do
  @moduledoc """
  Module for handling blog categories.
  """

  alias PayloadcmsGraphqlClient, as: GQL

  @attributes ~w(id name slug)a
  @enforce_keys @attributes
  defstruct @attributes

  @default_docs """
    {
      id
      name
      slug
    }
  """

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          slug: String.t()
        }

  def fetch_all() do
    with {:ok, results} when is_list(results) <- GQL.query_all_docs(:Categories, @default_docs) do
      results
      |> Enum.sort_by(&String.downcase(&1.name))
      |> Enum.map(&graphql_result_to_post/1)
      |> then(&{:ok, &1})
    else
      {:error, reason} ->
        {:error, reason}

      {:ok, results} ->
        {:error, "Unexpected result format: #{inspect(results)}"}

      response ->
        {:error, "Failed to fetch categories, response: #{inspect(response)}"}
    end
  end

  defp graphql_result_to_post(result) do
    %__MODULE__{
      id: result.id,
      name: result.name,
      slug: result.slug
    }
  end
end
