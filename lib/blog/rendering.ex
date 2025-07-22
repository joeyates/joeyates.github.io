defmodule Blog.Rendering do
  @moduledoc false

  def date_to_s(%{year: year, month: month, day: day}) do
    "#{prepend_zeroes(year, 4)}/#{prepend_zeroes(month)}/#{prepend_zeroes(day)}"
  end

  def prepend_zeroes(number, count \\ 2)

  def prepend_zeroes(number, count) when is_integer(number) do
    number
    |> Integer.to_string()
    |> prepend_zeroes(count)
  end

  def prepend_zeroes(number, count) do
    String.pad_leading(number, count, ["0"])
  end
end
