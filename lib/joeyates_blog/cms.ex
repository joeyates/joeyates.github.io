defmodule JoeyatesBlog.CMS do
  @moduledoc false

  alias Fermo.DatoCMS.GraphQLClient

  @posts_per_page 20

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

    result[:home]
  end

  def post_count() do
    result = GraphQLClient.query!(
      """
      query {
        _allPostsMeta { count }
      }
      """
    )

    result._allPostsMeta.count
  end

  def post(id, for_path \\ nil) do
    result = GraphQLClient.query_for_path!(
      for_path,
      """
      query Post($id: ItemId) {
        post(filter: {id: {eq: $id}}) {
          id
          _createdAt
          title
          body {
            blocks {
              __typename
              id
              image {
                url
              }
              caption
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

    result[:post]
  end

  def posts_per_page, do: @posts_per_page

  def posts_page(for_path, opts \\ []) do
    per_page = Keyword.get(opts, :per_page, @posts_per_page)
    page = Keyword.get(opts, :page, 1)
    skip = (page - 1) * per_page
    result = GraphQLClient.query_for_path!(
      for_path,
      """
      query($first: IntType, $skip: IntType)  {
        allPosts(orderBy: _createdAt_DESC, skip: $skip, first: $first) {
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

    result[:allPosts]
  end

  def latest_posts(for_page, opts \\ []) do
    count = Keyword.get(opts, :count, 10)

    posts_page(for_page)
    |> by_creation_date()
    |> Enum.take(count)
  end

  def by_creation_date(collection) do
    collection
    |> Enum.sort_by(&(&1._createdAt))
    |> Enum.reverse()
  end
end
