defmodule Ratatouille.Renderer.Attributes do
  @moduledoc """
  Functions for working with element attributes
  """

  alias Ratatouille.Constants

  @valid_color_codes Constants.colors() |> Map.values()
  @valid_color_codes_extended 0x11..0xe8
  @valid_attribute_codes Constants.attributes() |> Map.values()

  def to_terminal_color(code)
  when is_integer(code) and code in @valid_color_codes or code in @valid_color_codes_extended do
    code
  end

  def to_terminal_color(name) do
    Constants.color(name)
  end

  def to_terminal_attribute(code)
      when is_integer(code) and code in @valid_attribute_codes do
    code
  end

  def to_terminal_attribute(name) do
    Constants.attribute(name)
  end
end
