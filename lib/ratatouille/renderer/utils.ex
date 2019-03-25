defmodule Ratatouille.Renderer.Utils do
  @moduledoc """
  Utilities for rendering cells.
  """

  use Bitwise

  alias ExTermbox.{Cell, Constants, Position}

  def cell_generator(position, dir, template \\ Cell.empty()) do
    fn {ch, offset} ->
      %Cell{
        template
        | position:
            case dir do
              :vertical -> Position.translate_y(position, offset)
              :horizontal -> Position.translate_x(position, offset)
            end,
          ch: atoi(ch)
      }
    end
  end

  def cell_foreground(attrs) do
    base = attrs[:color] || Constants.color(:default)
    flags = attrs[:attributes] || []
    Enum.reduce(flags, base, fn flag, acc -> acc ||| flag end)
  end

  def atoi(str) do
    <<char::utf8>> = str
    char
  end
end
