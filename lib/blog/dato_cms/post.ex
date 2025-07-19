defmodule Blog.DatoCMS.Post do
  @moduledoc false

  alias Fermo.DatoCMS.GraphQLClient

  alias Blog.DatoCMS

  @enforce_keys ~w(id created_at title)a
  defstruct ~w(id created_at slug published_on old_path title description body categories)a

  @per_page 20

  def per_page, do: @per_page

  def count(opts \\ []) do
    only_published = Keyword.get(opts, :published, true)
    published_filter = if only_published, do: %{published: %{eq: true}}, else: %{}

    result =
      GraphQLClient.query!(
        """
        query($publishedFilter: PostModelFilter)  {
          _allPostsMeta(filter: $publishedFilter) { count }
        }
        """,
        %{publishedFilter: published_filter}
      )

    result._allPostsMeta.count
  end

  def get!(id, for_path \\ nil) do
    result =
      GraphQLClient.query_for_path!(
        for_path,
        """
        query Post($id: ItemId) {
          post(filter: {id: {eq: $id}}) {
            id
            _createdAt
            title
            description
            publishedOn
            body {
              blocks {
                __typename
                ... on ImagewithcaptionRecord {
                  id
                  caption
                  image {
                    url
                  }
                }
                ... on TableRecord {
                  id
                  data
                }
              }
              value
            }
            categories {
              name
              slug
            }
          }
        }
        """,
        %{id: id}
      )

    new(result.post)
  end

  def page(for_path, opts \\ []) do
    per_page = Keyword.get(opts, :per_page, @per_page)
    only_published = Keyword.get(opts, :published, true)
    page = Keyword.get(opts, :page, 1)
    skip = (page - 1) * per_page
    published_filter = if only_published, do: %{published: %{eq: true}}, else: %{}

    result =
      GraphQLClient.query_for_path!(
        for_path,
        """
        query($first: IntType, $skip: IntType, $publishedFilter: PostModelFilter)  {
          allPosts(orderBy: _createdAt_DESC, skip: $skip, first: $first, filter: $publishedFilter) {
            id
            _createdAt
            slug
            title
            oldPath
          }
        }
        """,
        %{skip: skip, first: per_page, publishedFilter: published_filter}
      )

    result.allPosts
    |> Enum.map(&new/1)
  end

  def latest(for_page, opts \\ []) do
    count = Keyword.get(opts, :count, 10)

    page(for_page, opts)
    |> DatoCMS.by_creation_date()
    |> Enum.reverse()
    |> Enum.take(count)
  end

  def new(data) when is_map(data) do
    {:ok, created_at, _} = DateTime.from_iso8601(data._createdAt)
    published_on = to_date(data[:publishedOn])

    data =
      data
      |> Map.put(:_createdAt, created_at)
      |> Map.put(:publishedOn, published_on)
      |> snakify_keys()

    struct!(__MODULE__, data)
  end

  def date(%__MODULE__{} = post) do
    post.published_on || post.created_at
  end

  defp snakify_keys(data) when is_map(data) do
    data
    |> Enum.map(fn {key, value} ->
      string = Atom.to_string(key)

      snakified =
        Regex.replace(
          ~r/([a-z])([A-Z])/,
          string,
          fn _, lower, upper -> "#{lower}_#{String.downcase(upper)}" end
        )
        |> String.replace(~r/^_/, "")
        |> String.to_atom()

      {snakified, value}
    end)
    |> Enum.into(%{})
  end

  defp to_date(nil), do: nil

  defp to_date(text), do: Date.from_iso8601!(text)
end
