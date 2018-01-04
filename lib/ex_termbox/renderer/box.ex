defmodule ExTermbox.Renderer.Box do
  alias ExTermbox.Position
  alias ExTermbox.Renderer.Box

  @enforce_keys [:top_left, :bottom_right]
  defstruct [:top_left, :bottom_right]

  def translate(%Box{top_left: %Position{x: x1, y: y1},
                     bottom_right: %Position{x: x2, y: y2}}, dx, dy) do
    %Box{
      top_left: %Position{x: x1 + dx, y: y1 + dy},
      bottom_right: %Position{x: x2 + dx, y: y2 + dy}
    }
  end

  def width(%Box{top_left: %Position{x: x1}, bottom_right: %Position{x: x2}}),
    do: x2 - x1

  def height(%Box{top_left: %Position{y: y1}, bottom_right: %Position{y: y2}}),
    do: y2 - y1

  def from_dimensions(width, height) do
    %Box{
      top_left: %Position{x: 0, y: 0},
      bottom_right: %Position{x: width, y: height}
    }
  end
end
