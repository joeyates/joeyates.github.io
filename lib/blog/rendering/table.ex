defmodule Blog.Rendering.Table do
  def render(%{data: data}, _dast, _options) do
    [~S(<table class="border-2 border-[#202000]">)] ++
      headers(data) ++
      rows(data) ++
      ["</table>"]
  end

  defp headers(%{columns: columns}) do
    ["<tr>"] ++
      Enum.map(columns, fn c -> "<th>#{c}</th>" end) ++
      ["</tr>"]
  end

  defp rows(%{columns: columns, data: data}) do
    keys = Enum.map(columns, &String.to_atom(&1))

    Enum.flat_map(
      data,
      fn row ->
        cells =
          Enum.map(
            keys,
            fn key ->
              ~s(<td class="border-[#404020] px-1">#{row[key]}</td>)
            end
          )

        [~S(<tr class="odd-[#f0f0d0] even-[#e0e0c0]">)] ++
          cells ++
          ["</tr>"]
      end
    )
  end
end
