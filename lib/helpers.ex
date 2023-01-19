defmodule Helpers do
  @moduledoc false

  defmacro __using__(_opts \\ %{}) do
    quote do
      import DatoCMS.GraphQLClient
      import DatoCMS.GraphQLClient.MetaTagHelpers
      import FermoHelpers.Links

      def environment, do: System.get_env("BUILD_ENV")

      def posts do
        result = query!("""
          query MyQuery {
            allPosts {
              id
              slug
              title
              oldPath
            }
          }
        """)

        result[:allPosts]
      end

      def post(id) do
        result = query!("""
          query Post($id: ItemId) {
            post(filter: {id: {eq: $id}}) {
              id
              title
              body {
                blocks
                value
                links
              }
              categories {
                name
                slug
              }
            }
          }
        """, %{id: id})

        result[:post]
      end

      @blank_dast %{
        value: %{
          schema: "dast", document: %{type: "root", children: []}
        }
      }

      def structured_text_to_html(dast) do
        dast = dast || @blank_dast
        DatoCMS.StructuredText.to_html(dast)
      end
    end
  end
end
