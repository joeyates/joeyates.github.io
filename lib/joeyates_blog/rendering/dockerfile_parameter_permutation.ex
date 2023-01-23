defmodule JoeyatesBlog.Rendering.DockerfileParameterPermutation do
  def render(block, dast, _options) do
    blocks = table_blocks(dast)
    is_first = block == hd(blocks)
    header = if is_first do
      [
        "<table>",
        "<tr>",
        "<th>ENTRYPOINT</th>",
        "<th>CMD</th>",
        "<th>run args</th>",
        "<th>OUTCOME</th>",
        "</tr>"
      ]
    else
      []
    end

    entrypoint = if block.entrypoint != "-" do
      "<strong>#{block.entrypoint}</strong>"
    else
      block.entrypoint
    end
    cmd = if block.cmdUsed do
      "<strong>#{block.cmd}</strong>"
    else
      block.cmd
    end
    runArgs = if block.runArgsUsed do
      "<strong>#{block.runArgs}</strong>"
    else
      block.runArgs
    end
    row = [
      "<tr>",
      "<td>#{entrypoint}</td>",
      "<td>#{cmd}</td>",
      "<td>#{runArgs}</td>",
      "<td>#{block.outcome}</td>",
      "</tr>"
    ]

    is_last = block == Enum.at(blocks, -1)
    footer = if is_last do
      ["</table>"]
    else
      []
    end

    header ++ row ++ footer
  end

  defp table_blocks(dast) do
    by_id = blocks_by_id(dast)
    block_ids(dast)
    |> Enum.map(&(by_id[&1]))
  end

  defp blocks_by_id(%{blocks: blocks}) do
    blocks
    |> Enum.into(
      %{},
      fn block ->
        {block.id, block}
      end
    )
  end

  defp block_ids(%{value: value}) do
    value.document.children
    |> Enum.filter(&(&1.type == "block"))
    |> Enum.map(&(&1.item))
  end
end
