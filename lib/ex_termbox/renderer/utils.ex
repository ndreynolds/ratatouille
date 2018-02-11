defmodule ExTermbox.Renderer.Utils do
  @moduledoc """
  Utilities for rendering cells.
  """

  alias ExTermbox.{Cell, Position}
  alias ExTermbox.Renderer.{Box, Canvas}

  def render_cells(cells, %Canvas{box: box, cells: canvas_cells} = canvas) do
    new_cells =
      for c <- cells,
          Box.contains?(box, c.position),
          do: {c.position, c},
          into: %{}

    %Canvas{canvas | cells: Map.merge(canvas_cells, new_cells)}
  end

  def cell_generator(position, dir, template \\ Cell.empty()) do
    fn {ch, offset} ->
      %Cell{
        template
        | position:
            case dir do
              :vertical -> Position.translate_y(position, offset)
              :horizontal -> Position.translate_x(position, offset)
            end,
          char: atoi(ch)
      }
    end
  end

  defp atoi(str) do
    <<char::utf8>> = str
    char
  end
end
