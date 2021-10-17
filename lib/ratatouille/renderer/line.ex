defmodule Ratatouille.Renderer.Line do
  @moduledoc """
  Primitives for rendering lines
  """

  alias ExTermbox.{Cell, Position}
  alias Ratatouille.Renderer.{Canvas, Cells}

  def render_horizontal(canvas, %Position{} = position, ch, len, attrs),
    do: render(canvas, :horizontal, position, ch, len, attrs)

  def render_vertical(canvas, %Position{} = position, ch, len, attrs),
    do: render(canvas, :vertical, position, ch, len, attrs)

  def render(canvas, orientation, %Position{} = position, ch, len, attrs)
  when orientation in [:horizontal, :vertical] do
    template = template_cell(attrs)
    cell_generator = Cells.generator(position, orientation, template)

    cells =
      [ch]
      |> Stream.cycle()
      |> Enum.zip(0..(len - 1))
      |> Enum.map(cell_generator)

    Canvas.merge_cells(canvas, cells)
  end

  defp template_cell(attrs) do
    %Cell{
      bg: Cells.background(attrs),
      fg: Cells.foreground(attrs),
      ch: nil,
      position: nil
    }
  end
end
