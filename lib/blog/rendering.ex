defmodule Blog.Rendering do
  @moduledoc false

  def date_to_s(%{year: year, month: month, day: day}) do
    "#{prepend_zeroes(year, 4)}/#{prepend_zeroes(month)}/#{prepend_zeroes(day)}"
  end

  def prepend_zeroes(n, count \\ 2)

  def prepend_zeroes(n, count) when is_integer(n) do
    Integer.to_string(n)
    |> prepend_zeroes(count)
  end

  def prepend_zeroes(n, count) do
    String.pad_leading(n, count, ["0"])
  end
end
