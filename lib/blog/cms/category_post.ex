defmodule Blog.CMS.CategoryPost do
  @moduledoc """
  Module for handling blog category post data.

  This module holds reduced compared to the full Post.
  """

  @attributes ~w(id title description slug)a
  @enforce_keys @attributes
  defstruct @attributes

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          description: String.t(),
          slug: String.t()
        }

  def new_from_graphql_result(result) do
    %__MODULE__{
      id: result.id,
      title: result.title,
      description: result.description,
      slug: result.slug
    }
  end
end
