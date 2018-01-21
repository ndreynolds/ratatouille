defmodule ExTermbox.Cell do
  @moduledoc """
  Represents a termbox cell, a character at a position, along with the cell's
  background and foreground colors.
  """

  alias ExTermbox.Constants

  @enforce_keys [:position, :char]
  defstruct position: nil,
            char: nil,
            bg: Constants.colors().default,
            fg: Constants.colors().white
end
