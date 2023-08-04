defmodule JoeyatesBlog.CMS.Post do
  @moduledoc false

  alias Fermo.DatoCMS.GraphQLClient

  alias JoeyatesBlog.CMS

  @enforce_keys ~w(id created_at title)a
  defstruct ~w(id created_at slug old_path title description body categories)a

  @per_page 20

  def per_page, do: @per_page

  def count() do
    result = GraphQLClient.query!(
      """
      query {
        _allPostsMeta { count }
      }
      """
    )

    result._allPostsMeta.count
  end

  def get!(id, for_path \\ nil) do
    result = GraphQLClient.query_for_path!(
      for_path,
      """
      query Post($id: ItemId) {
        post(filter: {id: {eq: $id}}) {
          id
          _createdAt
          title
          description
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
    page = Keyword.get(opts, :page, 1)
    skip = (page - 1) * per_page
    result = GraphQLClient.query_for_path!(
      for_path,
      """
      query($first: IntType, $skip: IntType)  {
        allPosts(orderBy: _createdAt_DESC, skip: $skip, first: $first, filter: {published: {eq: true}}) {
          id
          _createdAt
          slug
          title
          oldPath
        }
      }
      """,
      %{skip: skip, first: per_page}
    )

    result.allPosts
    |> Enum.map(&new/1)
  end

  def latest(for_page, opts \\ []) do
    count = Keyword.get(opts, :count, 10)

    page(for_page)
    |> CMS.by_creation_date()
    |> Enum.reverse()
    |> Enum.take(count)
  end

  def new(data) when is_map(data) do
    {:ok, created_at, _} = DateTime.from_iso8601(data._createdAt)
    data =
      data
      |> Map.put(:_createdAt, created_at)
      |> snakify_keys()

    struct!(__MODULE__, data)
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
end
