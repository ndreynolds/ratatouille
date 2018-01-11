defmodule ExTermbox.Position do
  alias ExTermbox.Position

  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def translate(%Position{x: x, y: y}, a, b), do: %Position{x: x + a, y: y + b}

  def translate_x(%Position{} = pos, a), do: translate(pos, a, 0)
  def translate_y(%Position{} = pos, b), do: translate(pos, 0, b)
end
