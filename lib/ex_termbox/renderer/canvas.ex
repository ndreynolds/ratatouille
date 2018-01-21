defmodule ExTermbox.Renderer.Canvas do
  @moduledoc false

  alias ExTermbox.{Bindings, Cell, Position}
  alias ExTermbox.Renderer.Box

  alias __MODULE__, as: Canvas

  @enforce_keys [:box]
  defstruct box: nil,
            cells: %{}

  def from_dimensions(x, y) do
    %Canvas{box: Box.from_dimensions(x, y)}
  end

  def padded(%Canvas{box: box} = canvas, size) do
    %Canvas{canvas | box: Box.padded(box, size)}
  end

  def translate(%Canvas{box: box} = canvas, dx, dy) do
    %Canvas{canvas | box: Box.translate(box, dx, dy)}
  end

  def render_to_strings(%Canvas{box: box, cells: cells_map}) do
    ys = 0..Box.height(box)
    xs = 0..Box.width(box)

    empty_cells = for y <- ys, x <- xs, do: empty_cell(x, y)
    filled_cells = Enum.map(empty_cells, &(fetch_cell(cells_map, &1)))

    filled_cells
    |> Enum.chunk_by(&row_idx/1)
    |> Enum.map(fn columns ->
      columns
      |> Enum.map(&cell_to_string/1)
      |> Enum.join()
    end)
  end

  def render_to_string(%Canvas{} = canvas),
    do: canvas |> render_to_strings() |> Enum.join("\n")

  def render_to_termbox(%Canvas{cells: cells}) do
    # TODO: only attempt to render cells in the canvas box
    cells
    |> Enum.each(fn {_pos, cell} -> Bindings.put_cell(cell) end)
  end

  defp cell_to_string(%Cell{char: char}),
    do: to_string([char])

  defp row_idx(%Cell{position: %Position{y: y}}), do: y

  defp fetch_cell(cells, empty_cell),
    do: Map.get(cells, empty_cell.position, empty_cell)

  defp empty_cell(x, y),
    do: %Cell{position: %Position{x: x, y: y}, char: ' '}
end
