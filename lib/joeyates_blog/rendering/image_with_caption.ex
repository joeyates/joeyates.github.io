defmodule JoeyatesBlog.Rendering.ImageWithCaption do
  def render(block, _dat, _options) do
    [
      ~s(
        <div class="w-full my-4 flex flex-col justify-center">
          <img src="#{block.image.url}?w=600"/>
          <p class="flex justify-center text-sm">#{block.caption}</p>
        </div>
      )
    ]
  end
end
