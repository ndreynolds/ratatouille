defmodule ExTermbox.Event do
  @moduledoc """
  Represents a termbox event. This can be a key press, click, or window resize.
  """

  @enforce_keys [:type, :mod, :key, :ch, :w, :h, :x, :y]
  defstruct [:type, :mod, :key, :ch, :w, :h, :x, :y]
end
