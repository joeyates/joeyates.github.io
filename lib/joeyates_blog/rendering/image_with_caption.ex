defmodule JoeyatesBlog.Rendering.ImageWithCaption do
  def render(block, _dat, _options) do
    [
      ~s(
        <div class="image_with_caption">
          <img src="#{block.image.url}?w=600"/>
          <p class="caption">#{block.caption}</p>
        </div>
      )
    ]
  end
end
