defmodule ExTermbox.Cell do
  @moduledoc """
  Represents a termbox cell, a character at a position, along with the cell's
  background and foreground colors.
  """

  alias __MODULE__, as: Cell
  alias ExTermbox.{Constants, Position}

  @type t :: %__MODULE__{
          position: Position.t(),
          char: non_neg_integer()
        }

  @enforce_keys [:position, :char]
  defstruct position: nil,
            char: nil,
            bg: Constants.colors().default,
            fg: Constants.colors().white

  def empty do
    %Cell{position: nil, char: nil}
  end
end
