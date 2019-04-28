defmodule Ratatouille.Renderer.Cells do
  @moduledoc """
  Functions for working with canvas cells.
  """
  use Bitwise

  alias Ratatouille.Renderer.Attributes

  alias ExTermbox.{Cell, Position}

  @doc """
  Computes a cell's foreground given a standardized attributes map.

  The foreground value is computed by taking the color's integer value and the
  integer values of any styling attributes (e.g., bold, underline) and computing
  the bitwise OR of all the values.
  """
  def foreground(attrs) do
    base = Attributes.to_terminal_color(attrs[:color] || :default)

    flags =
      for attr <- attrs[:attributes] || [] do
        Attributes.to_terminal_attribute(attr)
      end

    Enum.reduce(flags, base, fn flag, acc -> acc ||| flag end)
  end

  @doc """
  Computes a cell's background given a standardized attributes map.
  """
  def background(attrs) do
    Attributes.to_terminal_color(attrs[:background] || :default)
  end

  @doc """
  Given a starting position, orientation and cell template, returns a cell
  generator which can be used to iteratively generate a row or column of cells.
  """
  def generator(position, orientation, template \\ Cell.empty()) do
    fn {char_or_binary, offset} ->
      %Cell{
        template
        | position:
            case orientation do
              :vertical -> Position.translate_y(position, offset)
              :horizontal -> Position.translate_x(position, offset)
            end,
          ch: to_char(char_or_binary)
      }
    end
  end

  defp to_char(ch) when is_integer(ch), do: ch
  # TODO: Figure out how to handle trailing codepoints (see graphemes)
  defp to_char(<<ch::utf8, _rest::binary>>), do: ch
end
