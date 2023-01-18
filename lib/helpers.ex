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
            }
          }
        """)

        result[:allPosts]
      end
    end
  end
end
