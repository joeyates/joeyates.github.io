defmodule Helpers do
  @moduledoc false

  defmacro __using__(_opts \\ %{}) do
    quote do
      import DatoCMS.GraphQLClient.MetaTagHelpers
      import FermoHelpers.Links
      import JoeyatesBlog.Rendering, only: [
        date_to_s: 1,
        structured_text_to_html: 1
      ]
      alias JoeyatesBlog.CMS

      def environment, do: System.get_env("BUILD_ENV")
    end
  end
end
