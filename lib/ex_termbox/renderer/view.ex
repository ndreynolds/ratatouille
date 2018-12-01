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

  def text(attributes \\ %{}, content) when is_binary(content) do
    element(:text, Enum.into(attributes, %{content: content}), [])
  end

  def table_row(attributes \\ %{}, values) do
    element(:table_row, Enum.into(attributes, %{values: values}), [])
  end

  def sparkline(attributes \\ %{}, values) do
    element(:sparkline, Enum.into(attributes, %{values: values}), [])
  end

  def element(tag, children), do: element(tag, %{}, children)

  def element(tag, attributes, children)
      when is_atom(tag) and is_map(attributes) and is_list(children) do
    %Element{tag: tag, attributes: attributes, children: children}
  end

  def element(tag, attributes, children) when is_list(attributes) do
    element(tag, Enum.into(attributes, %{}), children)
  end

  ### Element Definition Macros

  defmacro table(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:table, attributes, block)

  defmacro panel(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:panel, attributes, block)

  defmacro bar(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:bar, attributes, block)

  defmacro row(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:row, attributes, block)

  defmacro column(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:column, attributes, block)

  defmacro label(attributes \\ Macro.escape(%{}), text_or_block)

  defmacro label(attributes, do: block),
    do: macro_element(:label, attributes, block)

  defmacro label(attributes, text_content) do
    quote do
      element(:label, unquote(attributes), [
        text(unquote(text_content))
      ])
    end
  end

  defmacro view(attributes \\ Macro.escape(%{}), do: block),
    do: macro_element(:view, attributes, block)

  defp macro_element(tag, attributes, block) do
    child_elements = extract_children(block)

    quote do
      element(unquote(tag), unquote(attributes), List.flatten(unquote(child_elements)))
    end
  end

  defp extract_children({:__block__, _meta, elements}), do: elements
  defp extract_children(element), do: [element]
end
