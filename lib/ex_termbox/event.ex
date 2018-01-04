defmodule ExTermbox.Event do
  @enforce_keys [:type, :mod, :key, :ch, :w, :h, :x, :y]
  defstruct [:type, :mod, :key, :ch, :w, :h, :x, :y]
end
