defmodule ExTermbox.Renderer.Box do
  @moduledoc false

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

  def padded(%Box{top_left: top_left, bottom_right: bottom_right}, size) do
    %Box{
      top_left: top_left |> Position.translate(size, size),
      bottom_right: bottom_right |> Position.translate(-size, -size)
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

  def from_dimensions(width, height, origin \\ %Position{x: 0, y: 0}) do
    dx = width - 1
    dy = height - 1

    %Box{
      top_left: origin,
      bottom_right: %Position{x: origin.x + dx, y: origin.y + dy}
    }
  end
end
