defmodule Helpers do
  @moduledoc false

  defmacro __using__(_opts \\ %{}) do
    quote do
      import DatoCMS.GraphQLClient.MetaTagHelpers
      import FermoHelpers.Links
      alias JoeyatesBlog.CMS

      def environment, do: System.get_env("BUILD_ENV")

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

      def date_to_s(%{year: year, month: month, day: day}) do
        "#{year}/#{month}/#{day}"
      end
    end
  end
end
