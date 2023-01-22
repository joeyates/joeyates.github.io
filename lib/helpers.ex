defmodule Helpers do
  @moduledoc false

  defmacro __using__(_opts \\ %{}) do
    quote do
      import Fermo.DatoCMS.GraphQLClient, only: [
        query!: 1, query!: 2, query_for_path!: 3
      ]
      import DatoCMS.GraphQLClient.MetaTagHelpers
      import FermoHelpers.Links

      @posts_per_page 20

      def environment, do: System.get_env("BUILD_ENV")

      def home(for_path) do
        result = query_for_path!(
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
        result = query!(
          """
          query {
            _allPostsMeta { count }
          }
          """
        )

        result._allPostsMeta.count
      end

      def posts_per_page, do: @posts_per_page

      def posts_page(for_path, opts \\ []) do
        per_page = Keyword.get(opts, :per_page, @posts_per_page)
        page = Keyword.get(opts, :page, 1)
        skip = (page - 1) * per_page
        result = query_for_path!(
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

      def by_creation_date(collection) do
        collection
        |> Enum.sort_by(&(&1._createdAt))
        |> Enum.reverse()
      end

      def latest_posts(for_page, opts \\ []) do
        count = Keyword.get(opts, :count, 10)

        posts_page(for_page)
        |> by_creation_date()
        |> Enum.take(count)
      end

      def post(id, for_path \\ nil) do
        result = query_for_path!(
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

      @blank_dast %{
        value: %{
          schema: "dast", document: %{type: "root", children: []}
        }
      }

      def structured_text_to_html(dast) do
        dast = dast || @blank_dast
        options = %{
          renderers: %{render_block: &render_block/3}
        }
        DatoCMS.StructuredText.to_html(dast, options)
      end

      def render_block(%{__typename: "ImagewithcaptionRecord"} = block, _dast, _options) do
        [~s(<div><h1>#{block.caption}</h1><p><img src="#{block.image.url}"></p></div>)]
      end
    end
  end
end
