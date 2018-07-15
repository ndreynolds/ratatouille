defmodule ExTermbox.Renderer.View do
  @moduledoc """
  Represents a renderable view of the terminal application.

  This API is still under development.
  """

  alias ExTermbox.Renderer.Element

  defmacro table(attributes \\ %{}, do: block),
    do: macro_element(:table, attributes, block)

  defmacro panel(attributes \\ %{}, do: block),
    do: macro_element(:panel, attributes, block)

  defmacro status_bar(attributes \\ %{}, do: block),
    do: macro_element(:status_bar, attributes, block)

  defmacro row(attributes \\ %{}, do: block),
    do: macro_element(:row, attributes, block)

  defmacro column(attributes \\ %{}, do: block),
    do: macro_element(:column, attributes, block)

  defmacro view(attributes \\ %{}, do: block),
    do: macro_element(:view, attributes, block)

  def table_row(attributes \\ %{}, values) do
    element(:table_row, attributes, values)
  end

  def element(tag, attributes, children) when is_list(attributes),
    do: element(tag, Enum.into(attributes, %{}), children)

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: children}
  end

  def element(tag, children) when is_atom(tag) and is_list(children) do
    %Element{tag: tag, children: children}
  end

  defp macro_element(tag, %{}, block),
    do: macro_element(tag, Macro.escape(%{}), block)

  defp macro_element(tag, attributes, block) do
    elements = extract_children(block)

    quote do
      element(unquote(tag), unquote(attributes), unquote(elements))
    end
  end

  defp extract_children({:__block__, _meta, elements}), do: elements
  defp extract_children(element), do: [element]
end
