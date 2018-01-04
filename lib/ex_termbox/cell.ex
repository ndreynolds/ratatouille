defmodule ExTermbox.Cell do
  alias ExTermbox.Constants

  @enforce_keys [:position, :char]
  defstruct [
    position: nil,
    char: nil,
    bg: Constants.colors.default,
    fg: Constants.colors.white
  ]
end
