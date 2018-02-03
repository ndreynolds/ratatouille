defmodule ExTermbox.Event do
  @moduledoc """
  Represents a termbox event. This can be a key press, click, or window resize.
  """

  @enforce_keys [:type]
  defstruct type: nil,
            mod: 0,
            key: 0,
            ch: 0,
            w: 0,
            h: 0,
            x: 0,
            y: 0
end
