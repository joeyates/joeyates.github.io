defmodule Blog.CMS.Post do
  @moduledoc """
  Module for handling blog posts.
  """

  alias PayloadcmsGraphqlClient, as: GQL
  alias PayloadcmsGraphqlClient.RichText

  @enforce_keys [:id, :title, :description, :slug, :body, :published_on]
  defstruct [:id, :title, :description, :slug, :body, :published_on]

  @default_docs """
    {
      id
      title
      slug
      description
      body
      publishedOn
    }
  """

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          description: String.t(),
          slug: String.t(),
          body: String.t(),
          published_on: Date.t()
        }

  def fetch_all(opts) do
    only_published = Keyword.get(opts, :only_published, true)
    query_options = [sort: "publishedOn"]

    query_options =
      if only_published do
        Keyword.put(query_options, :where, %{published: %{equals: true}})
      else
        query_options
      end

    with {:ok, results} when is_list(results) <-
           GQL.query_all_docs(:Posts, @default_docs, query_options) do
      results
      |> Enum.map(&graphql_result_to_post/1)
      |> then(&{:ok, &1})
    else
      {:error, reason} ->
        {:error, reason}

      {:ok, results} ->
        {:error, "Unexpected result format: #{inspect(results)}"}

      response ->
        {:error, "Failed to fetch posts, response: #{inspect(response)}"}
    end
  end

  @doc """
  Fetches a post by its slug.
  """
  def get_by_slug!(slug) do
    {:ok, result} = GQL.query_one_doc(:Posts, @default_docs, where: %{slug: %{equals: slug}})

    graphql_result_to_post(result)
  end

  defp graphql_result_to_post(result) do
    rendered =
      RichText.to_html(
        result.body,
        %{renderers: %{block: &render_block/2, upload: &render_upload/2}}
      )

    published_on =
      if result.publishedOn do
        {:ok, published_on_datetime, 0} = DateTime.from_iso8601(result.publishedOn)
        DateTime.to_date(published_on_datetime)
      end

    %__MODULE__{
      id: result.id,
      title: result.title,
      description: result.description,
      slug: result.slug,
      body: rendered,
      published_on: published_on
    }
  end

  defp render_block(
         %{type: "block", fields: %{blockType: "Code", language: language}} = node,
         _options
       ) do

    [
      ~s(<pre title="language: #{language}"><code class="language-#{language}">),
      String.replace(node.fields.code, "<", "&lt;"),
      "</code></pre>"
    ]
  end

  defp render_upload(%{type: "upload", value: value} = _node, _options) do
    %{width: width, height: height, url: path, alt: alt} = value
    url = image_url(path)

    [
      ~s(<img src="#{url}" alt="#{alt}" width="#{width}" height="#{height}">)
    ]
  end

  defp image_url(path), do: Path.join(image_base_url(), path)

  defp image_base_url do
    Application.fetch_env!(:blog, :image_base_url)
  end
end
