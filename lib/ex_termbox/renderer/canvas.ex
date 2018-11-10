defmodule ExTermbox.Renderer.Canvas do
  @moduledoc """
  A canvas represents a terminal window (or a subdivision of it) and a sparse
  mapping of positions to cells.

  A `%Canvas{}` struct can be rendered to different output formats. This includes
  the primary use-case of rendering to the termbox-managed window, but also
  rendering to strings, which is useful for testing.
  """

  alias ExTermbox.{Bindings, Cell, Position}
  alias ExTermbox.Renderer.Box

  alias __MODULE__, as: Canvas

  @type t :: %Canvas{box: Box.t(), cells: map()}

  @enforce_keys [:box]
  defstruct box: nil,
            cells: %{}

  @doc """
  Creates an empty canvas with the given dimensions.

  ## Examples

      iex> Canvas.from_dimensions(10, 20)
      %Canvas{
        box: %ExTermbox.Renderer.Box{
          top_left: %ExTermbox.Position{x: 0, y: 0},
          bottom_right: %ExTermbox.Position{x: 9, y: 19}
        },
        cells: %{}
      }

  """
  @spec from_dimensions(non_neg_integer(), non_neg_integer()) :: Canvas.t()
  def from_dimensions(x, y) do
    %Canvas{box: Box.from_dimensions(x, y)}
  end

  @spec put_box(Canvas.t(), Box.t()) :: Canvas.t()
  def put_box(%Canvas{} = canvas, box) do
    %Canvas{canvas | box: box}
  end

  @doc """
  Copies the canvas to a new one with the box padded on each side (top, left,
  bottom, right) by `size`. Pass a negative size to remove padding.
  """
  @spec padded(Canvas.t(), integer()) :: Canvas.t()
  def padded(%Canvas{box: box} = canvas, size) do
    %Canvas{canvas | box: Box.padded(box, size)}
  end

  @doc """
  Copies the canvas to a new one with the box consumed by the given `dx` and
  `dy`.

  The box is used to indicate the empty, renderable space on the canvas,
  so this might be called with a `dy` of 1 after rendering a line of text. The
  box is consumed left-to-right and top-to-bottom.
  """
  @spec consume(Canvas.t(), integer(), integer()) :: Canvas.t()
  def consume(%Canvas{box: box} = canvas, dx, dy) do
    %Canvas{canvas | box: Box.consume(box, dx, dy)}
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

  @spec translate(Canvas.t(), integer(), integer()) :: Canvas.t()
  def translate(%Canvas{box: box} = canvas, dx, dy) do
    %Canvas{canvas | box: Box.translate(box, dx, dy)}
  end

  @spec render_to_strings(Canvas.t()) :: list(String.t())
  def render_to_strings(%Canvas{cells: cells_map}) do
    positions = Map.keys(cells_map)
    max_y = positions |> Enum.map(fn %Position{y: y} -> y end) |> Enum.max()
    max_x = positions |> Enum.map(fn %Position{x: x} -> x end) |> Enum.max()

    empty_cells =
      for y <- 0..max_y,
          x <- 0..max_x,
          do: empty_cell(x, y)

    filled_cells = Enum.map(empty_cells, &fetch_cell(cells_map, &1))

    filled_cells
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

  def render_to_termbox(%Canvas{cells: cells}) do
    # TODO: only attempt to render cells in the canvas box
    for {_pos, cell} <- cells do
      :ok = Bindings.put_cell(cell)
    end

    :ok
  end

  defp cell_to_string(%Cell{char: char}), do: to_string([char])

  defp row_idx(%Cell{position: %Position{y: y}}), do: y

  defp fetch_cell(cells, empty_cell),
    do: Map.get(cells, empty_cell.position, empty_cell)

  defp empty_cell(x, y), do: %Cell{position: %Position{x: x, y: y}, char: ' '}
end
