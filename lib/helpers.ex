defmodule Helpers do
  @moduledoc false

  defmacro __using__(_opts \\ %{}) do
    quote do
      import Fermo.DatoCMS.GraphQLClient, only: [query!: 2, query_for_path!: 3]
      import DatoCMS.GraphQLClient.MetaTagHelpers
      import FermoHelpers.Links

      def environment, do: System.get_env("BUILD_ENV")

      def home(for_path \\ nil) do
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

      def posts(for_path \\ nil) do
        result = query_for_path!(
          for_path,
          """
          query {
            allPosts {
              id
              _createdAt
              slug
              title
              oldPath
            }
          }
          """,
          %{}
        )

        result[:allPosts]
      end

      def by_creation_date(collection) do
        collection
        |> Enum.sort_by(&(&1._createdAt))
        |> Enum.reverse()
      end

      def latestPosts(count \\ 10) do
        posts()
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
