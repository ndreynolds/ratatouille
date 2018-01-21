defmodule ExTermbox.Renderer.Utils do
  @moduledoc """
  Primitives for rendering text, lines and borders
  """

  alias ExTermbox.{Cell, Position}
  alias ExTermbox.Renderer.{Box, Canvas}

  @borders %{
    top: "─",
    top_right: "┐",
    right: "│",
    bottom_right: "┘",
    bottom: "─",
    bottom_left: "└",
    left: "│",
    top_left: "┌"
  }

  def render_border(%Canvas{box: box} = canvas) do
    width = Box.width(box)
    height = Box.height(box)

    canvas
    |> render_horizontal_line(Box.top_left(box), @borders.top, width)
    |> render_horizontal_line(Box.bottom_left(box), @borders.bottom, width)

    |> render_vertical_line(Box.top_left(box), @borders.left, height)
    |> render_vertical_line(Box.top_right(box), @borders.right, height)

    |> render_text(Box.top_left(box), @borders.top_left)
    |> render_text(Box.top_right(box), @borders.top_right)
    |> render_text(Box.bottom_left(box), @borders.bottom_left)
    |> render_text(Box.bottom_right(box), @borders.bottom_right)
  end

  def render_horizontal_line(canvas, %Position{} = position, ch, length) do
    [ch]
    |> Stream.cycle()
    |> Enum.zip(0..(length - 1))
    |> Enum.map(cell_generator(position, :horizontal))
    |> render_cells(canvas)
  end

  def render_vertical_line(canvas, %Position{} = position, ch, length) do
    [ch]
    |> Stream.cycle()
    |> Enum.zip(0..(length - 1))
    |> Enum.map(cell_generator(position, :vertical))
    |> render_cells(canvas)
  end

  def render_text(canvas, %Position{} = position, text) when is_binary(text) do
    text
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(cell_generator(position, :horizontal))
    |> render_cells(canvas)
  end

  def render_cells(cells, %Canvas{cells: canvas_cells} = canvas) do
    new_cells = for c <- cells, do: {c.position, c}, into: %{}
    %Canvas{canvas | cells: Map.merge(canvas_cells, new_cells)}
  end

  defp cell_generator(position, dir) do
    fn {ch, offset} ->
      %Cell{
        position:
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
