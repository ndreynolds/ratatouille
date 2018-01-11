defmodule ExTermbox.Renderer.Utils do
  @moduledoc """
  Primitives for rendering text, lines and borders
  """

  alias ExTermbox.{Bindings, Cell, Position}
  alias ExTermbox.Renderer.Box

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

  def render_border(%Box{} = box) do
    width = Box.width(box)
    height = Box.height(box)

    render_horizontal_line(Box.top_left(box), @borders.top, width)
    render_horizontal_line(Box.bottom_left(box), @borders.bottom, width)

    render_vertical_line(Box.top_left(box), @borders.left, height)
    render_vertical_line(Box.top_right(box), @borders.right, height)

    render_text(Box.top_left(box), @borders.top_left)
    render_text(Box.top_right(box), @borders.top_right)
    render_text(Box.bottom_left(box), @borders.bottom_left)
    render_text(Box.bottom_right(box), @borders.bottom_right)
  end

  def render_horizontal_line(%Position{} = position, ch, length) do
    Stream.cycle([ch])
    |> Enum.zip(0..(length - 1))
    |> Enum.map(cell_generator(position, :horizontal))
    |> render_cells()
  end

  def render_vertical_line(%Position{} = position, ch, length) do
    Stream.cycle([ch])
    |> Enum.zip(0..(length - 1))
    |> Enum.map(cell_generator(position, :vertical))
    |> render_cells()
  end

  def render_text(%Position{} = position, text) when is_binary(text) do
    String.graphemes(text)
    |> Enum.with_index()
    |> Enum.map(cell_generator(position, :horizontal))
    |> render_cells()
  end

  defp render_cells([]), do: []

  defp render_cells([%Cell{} = cell | rest]),
    do: [render_cell(cell) | render_cells(rest)]

  defp render_cell(%Cell{} = cell) do
    Bindings.put_cell(cell)
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
