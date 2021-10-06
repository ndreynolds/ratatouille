defmodule Ratatouille.Renderer.Canvas do
  @moduledoc """
  A canvas represents a terminal window, a subvision of it for rendering, and a
  sparse mapping of positions to cells.

  A `%Canvas{}` struct can be rendered to different output formats. This includes
  the primary use-case of rendering to the termbox-managed window, but also
  rendering to strings, which is useful for testing.
  """

  alias ExTermbox.{Cell, Position}
  alias Ratatouille.Renderer.Box

  alias __MODULE__, as: Canvas

  @type t :: %Canvas{render_box: Box.t(), outer_box: Box.t(), cells: map()}

  @enforce_keys [:render_box, :outer_box]
  defstruct render_box: nil,
            outer_box: nil,
            cells: %{}

  @doc """
  Creates an empty canvas with the given dimensions.

  ## Examples

      iex> Canvas.from_dimensions(10, 20)
      %Canvas{
        outer_box: %Ratatouille.Renderer.Box{
          top_left: %ExTermbox.Position{x: 0, y: 0},
          bottom_right: %ExTermbox.Position{x: 9, y: 19}
        },
        render_box: %Ratatouille.Renderer.Box{
          top_left: %ExTermbox.Position{x: 0, y: 0},
          bottom_right: %ExTermbox.Position{x: 9, y: 19}
        },
        cells: %{}
      }

  """
  @spec from_dimensions(non_neg_integer(), non_neg_integer()) :: Canvas.t()
  def from_dimensions(x, y) do
    %Canvas{
      render_box: Box.from_dimensions(x, y),
      outer_box: Box.from_dimensions(x, y)
    }
  end

  @spec put_box(Canvas.t(), Box.t()) :: Canvas.t()
  def put_box(%Canvas{} = canvas, render_box) do
    %Canvas{canvas | render_box: render_box}
  end

  @whitespace ?\s

  def fill_background(%Canvas{render_box: box, cells: cells} = canvas) do
    positions = Box.positions(box)

    filled_cells =
      for pos <- positions,
          do: {pos, %Cell{ch: @whitespace, position: pos}},
          into: %{}

    %Canvas{canvas | cells: Map.merge(cells, filled_cells)}
  end

  @doc """
  Copies the canvas to a new one with the render box padded on each side (top,
  left, bottom, right) by `size`. Pass a negative size to remove padding.
  """
  @spec padded(Canvas.t(), integer()) :: Canvas.t()
  def padded(%Canvas{render_box: box} = canvas, [top: top, left: left, bottom: bottom, right: right]) do
    %Canvas{canvas | render_box: Box.padded(box, top: top, left: left, bottom: bottom, right: right)}
  end

  @doc """
  Copies the canvas to a new one with the render box consumed by the given `dx`
  and `dy`.

  The render box is used to indicate the empty, renderable space on the canvas,
  so this might be called with a `dy` of 1 after rendering a line of text. The
  box is consumed left-to-right and top-to-bottom.
  """
  @spec consume(Canvas.t(), integer(), integer()) :: Canvas.t()
  def consume(%Canvas{render_box: box} = canvas, dx, dy) do
    %Canvas{canvas | render_box: Box.consume(box, dx, dy)}
  end

  @doc """
  Creates a new canvas with `n` rows (from the top) consumed.
  """
  @spec consume_rows(Canvas.t(), integer()) :: Canvas.t()
  def consume_rows(canvas, n), do: consume(canvas, 0, n)

  @doc """
  Creates a new canvas with `n` columns (from the left) consumed.
  """
  @spec consume_columns(Canvas.t(), integer()) :: Canvas.t()
  def consume_columns(canvas, n), do: consume(canvas, n, 0)

  @doc """
  Merges a list of cells into the canvas, provided that the cells are located
  within the canvas's rendering box. Returns a new canvas with the merged cells.
  """
  @spec merge_cells(Canvas.t(), list(Cell.t())) :: Canvas.t()
  def merge_cells(
        %Canvas{render_box: box, cells: canvas_cells} = canvas,
        cells
      ) do
    new_cells =
      for c <- cells,
          Box.contains?(box, c.position),
          do: {c.position, c},
          into: %{}

    %Canvas{canvas | cells: Map.merge(canvas_cells, new_cells)}
  end

  @spec translate(Canvas.t(), integer(), integer()) :: Canvas.t()
  def translate(%Canvas{render_box: box} = canvas, dx, dy) do
    %Canvas{canvas | render_box: Box.translate(box, dx, dy)}
  end

  @spec render_to_strings(Canvas.t()) :: list(String.t())
  def render_to_strings(%Canvas{cells: cells_map}) do
    positions = Map.keys(cells_map)

    ys = for %Position{y: y} <- positions, do: y
    xs = for %Position{x: x} <- positions, do: x

    y_max = Enum.max(ys, fn -> 0 end)
    x_max = Enum.max(xs, fn -> 0 end)

    cells =
      for y <- 0..y_max, x <- 0..x_max do
        pos = %Position{x: x, y: y}
        cells_map[pos] || %Cell{position: pos, ch: ' '}
      end

    cells
    |> Enum.chunk_by(&row_idx/1)
    |> Enum.map(fn columns ->
      columns
      |> Enum.map(&cell_to_string/1)
      |> Enum.join()
    end)
  end

  @spec render_to_string(Canvas.t()) :: String.t()
  def render_to_string(%Canvas{} = canvas),
    do: canvas |> render_to_strings() |> Enum.join("\n")

  @spec render_to_termbox(module(), Canvas.t()) :: :ok
  def render_to_termbox(bindings, %Canvas{cells: cells}) do
    # TODO: only attempt to render cells in the canvas box
    for {_pos, cell} <- cells do
      :ok = bindings.put_cell(cell)
    end

    :ok
  end

  defp cell_to_string(%Cell{ch: ch}), do: to_string([ch])

  defp row_idx(%Cell{position: %Position{y: y}}), do: y
end
