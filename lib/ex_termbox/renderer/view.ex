defmodule ExTermbox.Renderer.View do
  @moduledoc """
  Represents a renderable view of the terminal application.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{Box, Canvas, Element}

  ### View Rendering

  def render(canvas, attrs, children, render_fn) do
    canvas
    |> render_top_bar(attrs[:top_bar], render_fn)
    |> render_bottom_bar(attrs[:bottom_bar], render_fn)
    |> render_fn.(children)
  end

  defp render_top_bar(canvas, nil, _render_fn), do: canvas

  defp render_top_bar(%Canvas{box: box} = canvas, bar, render_fn) do
    canvas
    |> Canvas.put_box(Box.head(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(1)
  end

  defp render_bottom_bar(canvas, nil, _render_fn), do: canvas

  defp render_bottom_bar(%Canvas{box: box} = canvas, bar, render_fn) do
    canvas
    |> Canvas.put_box(Box.tail(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(1)
  end

  ### Element Definition

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

  ### Element Definition Macros

  defmacro table(attributes \\ %{}, do: block),
    do: macro_element(:table, attributes, block)

  defmacro panel(attributes \\ %{}, do: block),
    do: macro_element(:panel, attributes, block)

  defmacro bar(attributes \\ %{}, do: block),
    do: macro_element(:bar, attributes, block)

  defmacro row(attributes \\ %{}, do: block),
    do: macro_element(:row, attributes, block)

  defmacro column(attributes \\ %{}, do: block),
    do: macro_element(:column, attributes, block)

  defmacro view(attributes \\ %{}, do: block),
    do: macro_element(:view, attributes, block)

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
