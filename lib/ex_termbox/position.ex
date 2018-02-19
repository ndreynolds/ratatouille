defmodule ExTermbox.Position do
  @moduledoc """
  Represents a position on the screen by encoding a pair of cartesian
  coordinates. The origin is the top-left-most character on the screen
  `(0, 0)`, while x and y increase from left to right and top to bottom,
  respectively.
  """

  alias __MODULE__, as: Position

  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  @type t :: %__MODULE__{x: non_neg_integer, y: non_neg_integer}

  @doc """
  Translates (moves) a position by some delta x and y.

  Returns a new `%Position{}`.

  ## Examples

      iex> translate(%Position{x: 0, y: 0}, 1, 2)
      %Position{x: 1, y: 2}

  """
  @spec translate(t, integer, integer) :: t
  def translate(%Position{x: x, y: y}, dx, dy),
    do: %Position{x: x + dx, y: y + dy}

  @doc """
  Translate a position by a delta x.
  """
  @spec translate_x(t, integer) :: t
  def translate_x(%Position{} = pos, dx), do: translate(pos, dx, 0)

  @doc """
  Translate a position by a delta y.
  """
  @spec translate_y(t, integer) :: t
  def translate_y(%Position{} = pos, dy), do: translate(pos, 0, dy)
end
