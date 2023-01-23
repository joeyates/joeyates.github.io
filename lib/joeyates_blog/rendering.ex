defmodule JoeyatesBlog.Rendering do
  @moduledoc false

  alias JoeyatesBlog.Rendering.ImageWithCaption

  def date_to_s(%{year: year, month: month, day: day}) do
    "#{year}/#{month}/#{day}"
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
    ImageWithCaption.render(block)
  end
end
