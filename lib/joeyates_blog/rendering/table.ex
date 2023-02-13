defmodule JoeyatesBlog.Rendering.Table do
  def render(%{data: data}, _dast, _options) do
    [~S(<table class="table">)] ++
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
    keys = Enum.map(columns, &(String.to_atom(&1)))
    data
    |> Enum.flat_map(fn row ->
      cells =
        keys
        |> Enum.map(fn key ->
          "<td>#{row[key]}</td>"
        end)
      ["<tr>"] ++ cells ++ ["</tr>"]
    end)
  end
end
