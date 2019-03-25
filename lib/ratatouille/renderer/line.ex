defmodule Ratatouille.Renderer.Line do
  @moduledoc """
  Primitives for rendering lines
  """

  alias ExTermbox.Position
  alias Ratatouille.Renderer.{Canvas, Utils}

  def render_horizontal(canvas, %Position{} = position, ch, len),
    do: render(canvas, :horizontal, position, ch, len)

  def render_vertical(canvas, %Position{} = position, ch, len),
    do: render(canvas, :vertical, position, ch, len)

  def render(canvas, orientation, %Position{} = position, ch, len)
      when orientation in [:horizontal, :vertical] do
    cells =
      [ch]
      |> Stream.cycle()
      |> Enum.zip(0..(len - 1))
      |> Enum.map(Utils.cell_generator(position, orientation))

    Canvas.merge_cells(canvas, cells)
  end
end
