defmodule Blog.CMS.Category do
  @moduledoc """
  Module for handling blog categories.
  """

  alias PayloadcmsGraphqlClient, as: GQL
  alias Blog.CMS.CategoryPost

  @required_attributes ~w(id name slug)a
  @enforce_keys @required_attributes
  defstruct [posts: []] ++ @required_attributes

  @default_docs """
    {
      id
      name
      slug
      relatedPosts {
        docs {
          id
          title
          description
          slug
        }
      }
    }
  """

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          slug: String.t(),
          posts: [Blog.CMS.CategoryPost.t()]
        }

  def fetch_all() do
    with {:ok, results} when is_list(results) <- GQL.query_all_docs(:Categories, @default_docs) do
      results
      |> Enum.sort_by(&String.downcase(&1.name))
      |> Enum.map(&new_from_graphql_result/1)
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

  def new_from_graphql_result(result) do
    posts = Enum.map(result.relatedPosts.docs, &CategoryPost.new_from_graphql_result/1)

    %__MODULE__{
      id: result.id,
      name: result.name,
      slug: result.slug,
      posts: posts
    }
  end
end
