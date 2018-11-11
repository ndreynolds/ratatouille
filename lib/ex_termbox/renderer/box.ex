defmodule ExTermbox.Renderer.Box do
  @moduledoc """
  This defines the internal representation of a rectangular region---a box---for
  rendering, as well as logic for transforming these boxes.

  Boxes live on a coordinate plane. The y-axis is inverted so that the y values
  increase as the box's height grows.

      --------------> x
      |
      |    ________
      |    |      |
      |    |______|
      v
      y

  A `Box` struct stores the coordinates for two corners of the box---the
  top-left and bottom-right corners--from which the remaining attributes
  (height, width, other corners) can be computed.

       _________________
      |                 |
      |  A              |
      |                 |
      |                 |
      |                 |
      |              B  |
      |_________________|

      A: top-left corner, e.g. (0, 0)
      B: bottom-right corner, e.g. (10, 10)

  For rendering purposes, the outermost box will typically have a top-left
  corner (0, 0) and a bottom-right corner (x, y) where x is the number of rows
  and y is the number of columns on the terminal.

  This outermost box can then be subdivided as necessary to render different
  elements of the view.
  """

  alias ExTermbox.Position
  alias ExTermbox.Renderer.Box

  @enforce_keys [:top_left, :bottom_right]
  defstruct [:top_left, :bottom_right]

  def translate(
        %Box{
          top_left: %Position{x: x1, y: y1},
          bottom_right: %Position{x: x2, y: y2}
        },
        dx,
        dy
      ) do
    %Box{
      top_left: %Position{x: x1 + dx, y: y1 + dy},
      bottom_right: %Position{x: x2 + dx, y: y2 + dy}
    }
  end

  def consume(
        %Box{top_left: %Position{x: x1, y: y1}} = box,
        dx,
        dy
      ) do
    %Box{
      box
      | top_left: %Position{x: x1 + dx, y: y1 + dy}
    }
  end

  def padded(%Box{top_left: top_left, bottom_right: bottom_right}, size) do
    %Box{
      top_left: top_left |> Position.translate(size, size),
      bottom_right: bottom_right |> Position.translate(-size, -size)
    }
  end

  @doc """
  Given a box, returns a slice of the y axis with `n` rows from the top.
  """
  def head(box, n) do
    %Box{
      box
      | bottom_right: %Position{box.bottom_right | y: box.top_left.y + n - 1}
    }
  end

  @doc """
  Given a box, returns a slice of the y axis with `n` rows from the bottom.
  """
  def tail(box, n) do
    %Box{
      box
      | top_left: %Position{box.top_left | y: box.bottom_right.y - n + 1}
    }
  end

  def top_left(%Box{top_left: top_left}), do: top_left

  def top_right(%Box{top_left: %Position{y: y}, bottom_right: %Position{x: x}}),
    do: %Position{x: x, y: y}

  def bottom_left(%Box{top_left: %Position{x: x}, bottom_right: %Position{y: y}}),
    do: %Position{x: x, y: y}

  def bottom_right(%Box{bottom_right: bottom_right}), do: bottom_right

  def width(%Box{top_left: %Position{x: x1}, bottom_right: %Position{x: x2}}),
    do: x2 - x1

  def height(%Box{top_left: %Position{y: y1}, bottom_right: %Position{y: y2}}),
    do: y2 - y1

  def contains?(
        %Box{
          top_left: %Position{x: x1, y: y1},
          bottom_right: %Position{x: x2, y: y2}
        },
        %Position{x: x, y: y}
      ) do
    x in x1..x2 && y in y1..y2
  end

  def from_dimensions(width, height, origin \\ %Position{x: 0, y: 0}) do
    dx = width - 1
    dy = height - 1

    %Box{
      top_left: origin,
      bottom_right: %Position{x: origin.x + dx, y: origin.y + dy}
    }
  end
end
